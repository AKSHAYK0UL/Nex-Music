import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/exceptions/file_exist.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/helper_function/storage_permission/storage_permission.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final Repository _repository;
  final DownloadRepo _downloadRepo;
  final StoragePermission _storagePermission;

  DownloadBloc(this._repository, this._downloadRepo, this._storagePermission)
      : super(DownloadInitial()) {
    on<DownloadSongEvent>(_downloadSong);
  }

  Future<void> _downloadSong(
      DownloadSongEvent event, Emitter<DownloadState> emit) async {
    try {
      final isGranted = await _storagePermission.requestStoragePermission();
      if (isGranted) {
        final url =
            await _repository.getSongUrl(event.songData.vId, AudioQuality.high);

        final downloadPercentageStream = _downloadRepo
            .downloadSong(url.toString(), event.songData)
            .asBroadcastStream();

        await emit.forEach<double>(
          downloadPercentageStream,
          onData: (percentage) {
            if (percentage >= 100.0) {
              return DownloadInitial(); // Done
            } else {
              if (state is DownloadPercantageStatusState) {
                final currentState = state as DownloadPercantageStatusState;
                return currentState.copyWith(
                  percentageStream: downloadPercentageStream,
                  // sondData: event.songData, // already emitted
                );
              } else {
                return DownloadPercantageStatusState(
                  percentageStream: downloadPercentageStream,
                  songData: event.songData,
                );
              }
            }
          },
          onError: (error, __) {
            if (error is FileExistException) {
              emit(DownloadErrorState(errorMessage: error.message.toString()));
            }
            return DownloadErrorState(errorMessage: error.toString());
          },
        );
      } else {
        emit(DownloadErrorState(errorMessage: "permission denied"));
      }
    } catch (e) {
      emit(DownloadErrorState(errorMessage: e.toString()));
    }
  }
}
