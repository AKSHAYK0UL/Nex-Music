import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/isolates/isolateservices.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final Repository repository;

  PlaylistBloc(this.repository) : super(PlaylistInitial()) {
    on<GetPlaylistEvent>(_getPlaylist);
  }
  Future<void> _getPlaylist(
      GetPlaylistEvent event, Emitter<PlaylistState> emit) async {
    emit(LoadingState());
    debugPrint(event.playlistId);
    try {
      // final List<Songmodel> songslist =
      //     await repository.getPlayList(event.playlistId);
      final List<Songmodel> songslist =
          await IsolateServiceClass.getPlayListDataIsolate(
              repository, event.playlistId);
      emit(
        PlaylistDataState(playlistSongs: songslist),
      );
    } catch (e) {
      emit(
        ErrorState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
