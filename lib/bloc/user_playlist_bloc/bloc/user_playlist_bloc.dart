import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'user_playlist_event.dart';
part 'user_playlist_state.dart';

class UserPlaylistBloc extends Bloc<UserPlaylistEvent, UserPlaylistState> {
  final DbRepository _dbRepository;
  UserPlaylistBloc(this._dbRepository) : super(UserPlaylistInitial()) {
    on<CreatePlaylistEvent>(_createPlaylist);
    on<GetUserPlaylistsEvent>(_userPlaylist);
    on<AddSongToUserPlaylistEvent>(_addToUserPlaylist);
    // on<GetuserPlaylistSongsEvent>(_getuserPlaylistSongs);//moved to userplaylistsongbloc
  }
  Future<void> _createPlaylist(
      CreatePlaylistEvent event, Emitter<UserPlaylistState> emit) async {
    try {
      await _dbRepository.createPlaylistCollection(event.playlistName);
    } on FirebaseAuthException catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    }
  }

  void _userPlaylist(
      GetUserPlaylistsEvent event, Emitter<UserPlaylistState> emit) {
    emit(UserPlaylistLoadingState());
    try {
      final data = _dbRepository.getUserPlaylist();
      emit(UserPlaylistDataState(data: data));
    } on FirebaseAuthException catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _addToUserPlaylist(
      AddSongToUserPlaylistEvent event, Emitter<UserPlaylistState> emit) async {
    // emit(UserPlaylistLoadingState());
    try {
      await _dbRepository.addSongToPlaylist(event.playlistName, event.songData);
    } on FirebaseAuthException catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(UserPlaylistErrorState(errorMessage: e.toString()));
    }
  }

  // void _getuserPlaylistSongs(
  //     GetuserPlaylistSongsEvent event, Emitter<UserPlaylistState> emit) {
  //   emit(UserPlaylistLoadingState());
  //   try {
  //     final data = _dbRepository.getUserPlaylistSongs(event.playlistName);
  //     emit(UserPlaylistSongsDataState(data: data));
  //   } on FirebaseAuthException catch (e) {
  //     emit(UserPlaylistErrorState(errorMessage: e.toString()));
  //   } catch (e) {
  //     emit(UserPlaylistErrorState(errorMessage: e.toString()));
  //   }
  // }
}
