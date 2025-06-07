import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'user_playlist_song_event.dart';
part 'user_playlist_song_state.dart';

class UserPlaylistSongBloc
    extends Bloc<UserPlaylistSongEvent, UserPlaylistSongState> {
  final DbRepository _dbRepository;

  UserPlaylistSongBloc(this._dbRepository) : super(UserPlaylistSongInitial()) {
    on<GetuserPlaylistSongsEvent>(_getuserPlaylistSongs);
  }
  void _getuserPlaylistSongs(
      GetuserPlaylistSongsEvent event, Emitter<UserPlaylistSongState> emit) {
    emit(UserPlaylistSongLoadingState());
    try {
      final data = _dbRepository.getUserPlaylistSongs(event.playlistName);
      emit(UserPlaylistSongSongsDataState(data: data));
    } on FirebaseAuthException catch (e) {
      emit(UserPlaylistSongErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(UserPlaylistSongErrorState(errorMessage: e.toString()));
    }
  }
}
