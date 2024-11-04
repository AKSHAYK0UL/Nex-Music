import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final Repository repository;
  int index = 0;
  int playlistSize = 0;

  PlaylistBloc(this.repository) : super(PlaylistInitial()) {
    on<GetPlaylistEvent>(_getPlaylist);
    on<LoadMoreSongsEvent>(_loadMore);
  }

  Future<void> _getPlaylist(
      GetPlaylistEvent event, Emitter<PlaylistState> emit) async {
    index = 0; //reset it to 0
    emit(LoadingState());
    debugPrint(event.playlistId);
    try {
      final playlistData =
          await repository.getPlayList(event.playlistId, index);
      playlistSize = playlistData.playlistSize;
      index = playlistData.playlistSongs.length;
      emit(
        PlaylistDataState(
          playlistSongs: playlistData.playlistSongs,
          totalSongs: playlistData.playlistSize,
        ),
      );
    } catch (e) {
      emit(
        ErrorState(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadMore(
      LoadMoreSongsEvent event, Emitter<PlaylistState> emit) async {
    if (state is PlaylistDataState && index < playlistSize) {
      final currentState = state as PlaylistDataState;
      if (currentState.isLoading == false) {
        // Emit loading state with current playlist songs
        emit(currentState.copyWith(isLoading: true));
        debugPrint("Loading More Data");

        // Fetch more songs
        final playlistData =
            await repository.getPlayList(event.playlistId, index);
        index = currentState.playlistSongs.length +
            playlistData.playlistSongs.length;

        // Emit the updated state with new songs and reset loading
        emit(currentState.copyWith(
          isLoading: false,
          playlistSongs: [
            ...currentState.playlistSongs,
            ...playlistData.playlistSongs,
          ],
        ));
      }
    }
  }
}
