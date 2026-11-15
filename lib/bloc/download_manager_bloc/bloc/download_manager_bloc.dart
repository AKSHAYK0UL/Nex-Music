import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/exceptions/file_exist.dart';
import 'package:nex_music/core/services/download_notification_service.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_paused_download.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/helper_function/storage_permission/storage_permission.dart';
import 'package:nex_music/model/download_task_model.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:path_provider/path_provider.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

// Manages multiple concurrent downloads.
// Each download gets its own CancelToken so downloads can be individually
// paused cancelled + bytes recorded or deleted cancelled + file removed.
class DownloadManagerBloc
    extends Bloc<DownloadManagerEvent, DownloadManagerState> {
  final Repository _repository;
  final DownloadRepo _downloadRepo;
  final StoragePermission _storagePermission;
  final DownloadNotificationService _notificationService;

  // Cancel tokens keyed by vId only while a download is active.
  final Map<String, CancelToken> _cancelTokens = {};

  // Bytes downloaded so far (for resume), keyed by vId.
  final Map<String, int> _downloadedBytes = {};

  DownloadManagerBloc(
    this._repository,
    this._downloadRepo,
    this._storagePermission,
    this._notificationService,
  ) : super(DownloadManagerState.initial()) {
    on<EnqueueDownloadEvent>(_onEnqueue);
    on<PauseDownloadEvent>(_onPause);
    on<ResumeDownloadEvent>(_onResume);
    on<CancelDownloadEvent>(_onCancel);
    on<RestorePausedDownloadsEvent>(_onRestore);
    on<_ProgressUpdateEvent>(_onProgress);
    on<_DownloadCompletedEvent>(_onCompleted);
    on<_DownloadErrorEvent>(_onError);
    on<_RemoveCompletedTaskEvent>(_onRemoveCompleted);

    // Restore any paused downloads left over from a previous session.
    add(RestorePausedDownloadsEvent());
  }

  //  Public event handlers

  // Restore paused tasks persisted in Hive from the previous app session.
  Future<void> _onRestore(RestorePausedDownloadsEvent event,
      Emitter<DownloadManagerState> emit) async {
    try {
      final saved = HiveDataBaseSingleton.instance.allPausedDownloads;
      if (saved.isEmpty) return;

      Directory? downloadDir;
      try {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          downloadDir = Directory('${externalDir.path}/downloads');
        }
      } catch (_) {}

      var newState = state;
      for (final entry in saved) {
        final song = entry.songData;
        if (song == null) continue;

        // Skip if a task for this vId already exists
        if (newState.hasTask(entry.vId)) continue;

        // If the download was already completed on disk (has .json metadata and audio file),
        // remove it from Hive and don't restore it as a pending task.
        if (downloadDir != null && downloadDir.existsSync()) {
          final fileName = song.songName + song.vId;
          final metaFile = File('${downloadDir.path}/$fileName.json');
          final m4a = File('${downloadDir.path}/$fileName.m4a');
          final opus = File('${downloadDir.path}/$fileName.opus');
          if (metaFile.existsSync() &&
              (m4a.existsSync() || opus.existsSync())) {
            await HiveDataBaseSingleton.instance
                .removePausedDownload(entry.vId);
            continue;
          }
        }

        // Check if there is an existing partial file on disk to get the accurate downloaded bytes.
        int bytes = entry.downloadedBytes;
        if (downloadDir != null && downloadDir.existsSync()) {
          final fileName = song.songName + song.vId;
          final m4a = File('${downloadDir.path}/$fileName.m4a');
          final opus = File('${downloadDir.path}/$fileName.opus');
          if (m4a.existsSync()) {
            final len = m4a.lengthSync();
            if (len > bytes) bytes = len;
          } else if (opus.existsSync()) {
            final len = opus.lengthSync();
            if (len > bytes) bytes = len;
          }
        }

        newState = newState.withTask(
          entry.vId,
          DownloadTaskModel(
            songData: song,
            status: DownloadTaskStatus.paused,
            progress: entry.progress,
            downloadedBytes: bytes,
          ),
        );
        // Also pre-populate the in-memory bytes map so resume works instantly.
        _downloadedBytes[entry.vId] = bytes;
      }
      emit(newState);
    } catch (e) {
      debugPrint('DownloadManagerBloc _onRestore error: $e');
    }
  }

  Future<void> _onEnqueue(
      EnqueueDownloadEvent event, Emitter<DownloadManagerState> emit) async {
    final vId = event.songData.vId;

    // Ignore if already queued / downloading / paused.
    final existing = state.task(vId);
    if (existing != null &&
        (existing.status == DownloadTaskStatus.queued ||
            existing.status == DownloadTaskStatus.downloading ||
            existing.status == DownloadTaskStatus.paused)) {
      return;
    }

    final isGranted = await _storagePermission.requestStoragePermission;
    if (!isGranted) {
      emit(state.withTask(
        vId,
        DownloadTaskModel(
          songData: event.songData,
          status: DownloadTaskStatus.error,
          errorMessage: "Storage permission denied",
        ),
      ));
      return;
    }

    // Mark as queued immediately so the UI reacts.
    emit(state.withTask(
      vId,
      DownloadTaskModel(
        songData: event.songData,
        status: DownloadTaskStatus.queued,
      ),
    ));

    // Persist immediately in Hive as a pending task so if the app is killed right now, the data will be store
    await HiveDataBaseSingleton.instance.savePausedDownload(
      HivePausedDownload(
        vId: vId,
        songDataJson: jsonEncode(event.songData.toJson()),
        downloadedBytes: 0,
        progress: 0.0,
      ),
    );

    _startDownload(event.songData, resumeFromBytes: 0);
  }

  Future<void> _onPause(
      PauseDownloadEvent event, Emitter<DownloadManagerState> emit) async {
    final vId = event.vId;
    final token = _cancelTokens.remove(vId);
    if (token != null && !token.isCancelled) {
      token.cancel('paused');
    }

    final task = state.task(vId);
    if (task == null) return;

    final bytes = _downloadedBytes[vId] ?? task.downloadedBytes;
    final progress = task.progress;

    emit(state.withTask(
      vId,
      task.copyWith(
        status: DownloadTaskStatus.paused,
        downloadedBytes: bytes,
        progress: progress,
      ),
    ));

    // Persist so the paused task survives app restarts.
    await HiveDataBaseSingleton.instance.savePausedDownload(
      HivePausedDownload(
        vId: vId,
        songDataJson: jsonEncode(task.songData.toJson()),
        downloadedBytes: bytes,
        progress: progress,
      ),
    );

    await _notificationService.showPaused(
      vId: vId,
      songName: task.songData.songName,
      progress: progress.toInt(),
    );
  }

  Future<void> _onResume(
      ResumeDownloadEvent event, Emitter<DownloadManagerState> emit) async {
    final vId = event.vId;
    final task = state.task(vId);
    if (task == null || task.status != DownloadTaskStatus.paused) return;

    // Do NOT remove from Hive Keep it saved in Hive so if the app is killed while downloading again, it survives

    emit(state.withTask(
      vId,
      task.copyWith(status: DownloadTaskStatus.downloading),
    ));

    _startDownload(task.songData, resumeFromBytes: task.downloadedBytes);
  }

  Future<void> _onCancel(
      CancelDownloadEvent event, Emitter<DownloadManagerState> emit) async {
    final vId = event.vId;

    // Cancel any running download.
    final token = _cancelTokens.remove(vId);
    if (token != null && !token.isCancelled) {
      token.cancel('cancelled');
    }
    _downloadedBytes.remove(vId);

    // Clear any persisted pause record for this task.
    await HiveDataBaseSingleton.instance.removePausedDownload(vId);

    // Delete partial audio file if it exists.
    await _deletePartialFile(vId);

    // Remove task from state and cancel its notification.
    emit(state.withoutTask(vId));
    await _notificationService.cancel(vId);
  }

  //  Internal event handlers

  void _onProgress(
      _ProgressUpdateEvent event, Emitter<DownloadManagerState> emit) {
    final task = state.task(event.vId);
    if (task == null) return;

    // If task was already paused by user, ignore trailing stream updates
    if (task.status == DownloadTaskStatus.paused) return;

    _downloadedBytes[event.vId] = event.downloadedBytes;

    emit(state.withTask(
      event.vId,
      task.copyWith(
        status: DownloadTaskStatus.downloading,
        progress: event.progress,
        downloadedBytes: event.downloadedBytes,
      ),
    ));

    //  notification updates to every ~5% to avoid flooding.
    final lastNotifProgress =
        ((task.progress / 5).floor()) * 5; // previous 5% bucket
    final newNotifProgress = ((event.progress / 5).floor()) * 5;
    if (newNotifProgress > lastNotifProgress || event.progress >= 99) {
      _notificationService.showProgress(
        vId: event.vId,
        songName: task.songData.songName,
        progress: event.progress.toInt(),
      );

      // Periodically update Hive so if app is killed suddenly, progress is saved!
      HiveDataBaseSingleton.instance.savePausedDownload(
        HivePausedDownload(
          vId: event.vId,
          songDataJson: jsonEncode(task.songData.toJson()),
          downloadedBytes: event.downloadedBytes,
          progress: event.progress,
        ),
      );
    }
  }

  void _onCompleted(
      _DownloadCompletedEvent event, Emitter<DownloadManagerState> emit) {
    _cancelTokens.remove(event.vId);
    _downloadedBytes.remove(event.vId);

    // Clear any persisted pause record (task was resumed then completed).
    HiveDataBaseSingleton.instance.removePausedDownload(event.vId);

    final task = state.task(event.vId);
    if (task == null) return;

    emit(state.withTask(
      event.vId,
      task.copyWith(
        status: DownloadTaskStatus.completed,
        progress: 100.0,
      ),
    ));

    _notificationService.showCompleted(
      vId: event.vId,
      songName: task.songData.songName,
    );

    // download lyrics in the background.
    _downloadRepo
        .saveLyricsForSong(task.songData, _repository)
        .catchError((_) {});

    // Remove from active tasks list after a short delay so UI can show.
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        add(_RemoveCompletedTaskEvent(vId: event.vId));
      }
    });
  }

  void _onError(_DownloadErrorEvent event, Emitter<DownloadManagerState> emit) {
    _cancelTokens.remove(event.vId);
    _downloadedBytes.remove(event.vId);

    final task = state.task(event.vId);
    if (task == null) return;

    // FileExistException  treat as complete.
    if (event.errorMessage.contains('already exists') ||
        event.errorMessage.contains('FileExist')) {
      emit(state.withTask(
        event.vId,
        task.copyWith(status: DownloadTaskStatus.completed, progress: 100.0),
      ));
      _notificationService.showCompleted(
          vId: event.vId, songName: task.songData.songName);
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) add(_RemoveCompletedTaskEvent(vId: event.vId));
      });
      return;
    }

    emit(state.withTask(
      event.vId,
      task.copyWith(
        status: DownloadTaskStatus.error,
        errorMessage: event.errorMessage,
      ),
    ));

    _notificationService.showError(
      vId: event.vId,
      songName: task.songData.songName,
      error: event.errorMessage,
    );
  }

  //  Private helpers

  // Starts or resumes a download for songData
  void _startDownload(Songmodel songData, {required int resumeFromBytes}) {
    final vId = songData.vId;
    final cancelToken = CancelToken();
    _cancelTokens[vId] = cancelToken;

    () async {
      try {
        final songRawInfo = await _repository.getSongUrl(
            vId, HiveDataBaseSingleton.instance.getData.downloadQuality);

        if (cancelToken.isCancelled || isClosed) return;

        // Mark as actively downloading once the URL is ready.
        add(_ProgressUpdateEvent(
          vId: vId,
          progress: resumeFromBytes > 0
              ? ((resumeFromBytes / songRawInfo.totalBytes) * 100)
                  .clamp(0.0, 99.0)
              : 0.0,
          downloadedBytes: resumeFromBytes,
        ));

        final stream = _downloadRepo
            .downloadSong(
              songRawInfo,
              songData,
              cancelToken: cancelToken,
              resumeFromBytes: resumeFromBytes,
            )
            .asBroadcastStream();

        await for (final percent in stream) {
          if (isClosed || cancelToken.isCancelled) break;
          // Approximate bytes from percentage.
          final approxBytes =
              ((percent / 100) * songRawInfo.totalBytes).toInt();
          add(_ProgressUpdateEvent(
            vId: vId,
            progress: percent,
            downloadedBytes: approxBytes,
          ));
        }

        // Stream closed without cancel -> completed.
        if (!cancelToken.isCancelled && !isClosed) {
          add(_DownloadCompletedEvent(vId: vId));
        }
      } on FileExistException catch (e) {
        if (!isClosed) {
          add(_DownloadErrorEvent(vId: vId, errorMessage: e.message));
        }
      } catch (e) {
        if (!isClosed && !cancelToken.isCancelled) {
          add(_DownloadErrorEvent(vId: vId, errorMessage: e.toString()));
        }
        debugPrint('DownloadManagerBloc _startDownload error: $e');
      }
    }();
  }

  Future<void> _deletePartialFile(String vId) async {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return;
      final downloadDir = Directory('${externalDir.path}/downloads');
      if (!downloadDir.existsSync()) return;

      final files = downloadDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains(vId));

      for (final file in files) {
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _onRemoveCompleted(
      _RemoveCompletedTaskEvent event, Emitter<DownloadManagerState> emit) {
    emit(state.withoutTask(event.vId));
  }

  /// Persists any currently downloading or queued tasks to Hive so they can be
  /// restored in paused state if the app closes or is terminated.
  void persistActiveDownloads() {
    for (final task in state.activeTasks) {
      if (task.status == DownloadTaskStatus.downloading ||
          task.status == DownloadTaskStatus.queued ||
          task.status == DownloadTaskStatus.paused) {
        final bytes =
            _downloadedBytes[task.songData.vId] ?? task.downloadedBytes;
        HiveDataBaseSingleton.instance.savePausedDownload(
          HivePausedDownload(
            vId: task.songData.vId,
            songDataJson: jsonEncode(task.songData.toJson()),
            downloadedBytes: bytes,
            progress: task.progress,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) token.cancel('bloc closed');
    }
    _cancelTokens.clear();
    persistActiveDownloads();
    return super.close();
  }
}

// Internal event used to remove a completed task from the visible list.
final class _RemoveCompletedTaskEvent extends DownloadManagerEvent {
  final String vId;
  _RemoveCompletedTaskEvent({required this.vId});
}
