import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nex_music/helper_function/storage_permission/storage_permission.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';

part 'offline_songs_event.dart';
part 'offline_songs_state.dart';

class OfflineSongsBloc extends Bloc<OfflineSongsEvent, OfflineSongsState> {
  final DownloadRepo _downloadRepo;

  final StoragePermission _storagePermission;
  OfflineSongsBloc(this._downloadRepo, this._storagePermission)
      : super(OfflineSongsInitial()) {
    on<LoadOfflineSongsEvent>(_loadOfflineSongs);
    on<DeleteDownloadedSongEvent>(_deleteDownloadedSong);
  }
  //load
  Future<void> _loadOfflineSongs(
      LoadOfflineSongsEvent event, Emitter<OfflineSongsState> emit) async {
    emit(OfflineSongsLoadingState());

    try {
      final storagePermissionStatus =
          await _storagePermission.checkStoragePermissionStatus;
      if (storagePermissionStatus) {
        final streamData = _downloadRepo.loadOfflineSongs;
        emit(OfflineSongsDataState(data: streamData));
      } else {
        final requestStoragePermission =
            await _storagePermission.requestStoragePermission;
        if (requestStoragePermission) {
          add(LoadOfflineSongsEvent());
        } else {
          emit(OfflineSongsErrorState(errorMessage: "Permission Denied"));
        }
      }
    } catch (e) {
      emit(OfflineSongsErrorState(errorMessage: e.toString()));
    }
  }

  //delete
  Future<void> _deleteDownloadedSong(
      DeleteDownloadedSongEvent event, Emitter<OfflineSongsState> emit) async {
    try {
      await _downloadRepo.deleteDownLoadedSong(event.songData);
      add(LoadOfflineSongsEvent());
    } catch (e) {
      print("DELETE ERROR ${e.toString()}@@@@@");
      emit(OfflineSongsErrorState(errorMessage: e.toString()));
    }
  }
}
