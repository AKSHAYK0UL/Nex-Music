part of 'download_manager_bloc.dart';

sealed class DownloadManagerEvent {}

// Queue a new song for download. Ignored if it is already queued/downloading.
final class EnqueueDownloadEvent extends DownloadManagerEvent {
  final Songmodel songData;
  EnqueueDownloadEvent({required this.songData});
}

// Pause an active download.
final class PauseDownloadEvent extends DownloadManagerEvent {
  final String vId;
  PauseDownloadEvent({required this.vId});
}

// Resume a paused download.
final class ResumeDownloadEvent extends DownloadManagerEvent {
  final String vId;
  ResumeDownloadEvent({required this.vId});
}

// Cancel and remove a download from the queue (deletes partial file).
final class CancelDownloadEvent extends DownloadManagerEvent {
  final String vId;
  CancelDownloadEvent({required this.vId});
}

// Internal progress update emitted from the download isolate.
final class _ProgressUpdateEvent extends DownloadManagerEvent {
  final String vId;
  final double progress;
  final int downloadedBytes;
  _ProgressUpdateEvent({
    required this.vId,
    required this.progress,
    required this.downloadedBytes,
  });
}

// Internal: a download completed successfully.
final class _DownloadCompletedEvent extends DownloadManagerEvent {
  final String vId;
  _DownloadCompletedEvent({required this.vId});
}

// Internal: a download failed.
final class _DownloadErrorEvent extends DownloadManagerEvent {
  final String vId;
  final String errorMessage;
  _DownloadErrorEvent({required this.vId, required this.errorMessage});
}
