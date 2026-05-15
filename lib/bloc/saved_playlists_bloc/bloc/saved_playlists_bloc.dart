import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/saved_playlist_model.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'saved_playlists_event.dart';
part 'saved_playlists_state.dart';

class SavedPlaylistsBloc extends Bloc<SavedPlaylistsEvent, SavedPlaylistsState> {
  final DbRepository _dbRepository;
  Stream<List<SavedPlaylistModel>>? _cachedStream;

  SavedPlaylistsBloc(this._dbRepository) : super(SavedPlaylistsInitial()) {
    on<AddToSavedPlaylistsEvent>(_addToSavedPlaylists);
    on<IsPlaylistSavedEvent>(_checkIfPlaylistSaved);
    on<RemoveFromSavedPlaylistsEvent>(_removeFromSavedPlaylists);
    on<GetSavedPlaylistsEvent>(_getSavedPlaylists);
  }

  Future<void> _addToSavedPlaylists(
      AddToSavedPlaylistsEvent event, Emitter<SavedPlaylistsState> emit) async {
    try {
      await _dbRepository.addToSavedPlaylists(event.playlist);
      emit(IsPlaylistSavedState(
        isSaved: true, 
        playlistId: event.playlist.playListId,
        playlists: _cachedStream,
      ));
      
      if (_cachedStream != null) {
        emit(SavedPlaylistsDataState(
          playlists: _cachedStream!,
          lastIsSaved: true,
          lastPlaylistId: event.playlist.playListId,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    }
  }

  Future<void> _checkIfPlaylistSaved(
      IsPlaylistSavedEvent event, Emitter<SavedPlaylistsState> emit) async {
    try {
      final isSaved = await _dbRepository.isPlaylistSaved(event.playlistId);
      emit(IsPlaylistSavedState(
        isSaved: isSaved, 
        playlistId: event.playlistId,
        playlists: _cachedStream,
      ));
      
      if (_cachedStream != null) {
        emit(SavedPlaylistsDataState(
          playlists: _cachedStream!,
          lastIsSaved: isSaved,
          lastPlaylistId: event.playlistId,
        ));
      }
    } catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    }
  }

  Future<void> _removeFromSavedPlaylists(
      RemoveFromSavedPlaylistsEvent event, Emitter<SavedPlaylistsState> emit) async {
    try {
      await _dbRepository.removeFromSavedPlaylists(event.playlistId);
      emit(IsPlaylistSavedState(
        isSaved: false, 
        playlistId: event.playlistId,
        playlists: _cachedStream,
      ));
      
      if (_cachedStream != null) {
        emit(SavedPlaylistsDataState(
          playlists: _cachedStream!,
          lastIsSaved: false,
          lastPlaylistId: event.playlistId,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    }
  }

  void _getSavedPlaylists(
      GetSavedPlaylistsEvent event, Emitter<SavedPlaylistsState> emit) {
    if (_cachedStream == null) {
      emit(LoadingStateSavedPlaylists());
    }
    
    try {
      _cachedStream = _dbRepository.getSavedPlaylists();
      emit(SavedPlaylistsDataState(playlists: _cachedStream!));
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateSavedPlaylists(errorMessage: e.toString()));
    }
  }
}
