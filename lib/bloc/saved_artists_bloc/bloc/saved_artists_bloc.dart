import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'saved_artists_event.dart';
part 'saved_artists_state.dart';

class SavedArtistsBloc extends Bloc<SavedArtistsEvent, SavedArtistsState> {
  final DbRepository _dbRepository;

  SavedArtistsBloc(this._dbRepository) : super(SavedArtistsInitial()) {
    on<AddToSavedArtistsEvent>(_addToSavedArtists);
    on<IsArtistSavedEvent>(_checkIfArtistSaved);
    on<RemoveFromSavedArtistsEvent>(_removeFromSavedArtists);
    on<GetSavedArtistsEvent>(_getSavedArtists);
  }

  Future<void> _addToSavedArtists(
      AddToSavedArtistsEvent event, Emitter<SavedArtistsState> emit) async {
    emit(LoadingStateSavedArtists());
    try {
      await _dbRepository.addToSavedArtists(event.artist);
      final artistId = event.artist.artist.artistId ?? '';
      emit(IsArtistSavedState(isSaved: true, artistId: artistId));
    } catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    }
  }

  Future<void> _checkIfArtistSaved(
      IsArtistSavedEvent event, Emitter<SavedArtistsState> emit) async {
    try {
      final isSaved = await _dbRepository.isArtistSaved(event.artistId);
      emit(IsArtistSavedState(isSaved: isSaved, artistId: event.artistId));
    } catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    }
  }

  Future<void> _removeFromSavedArtists(
      RemoveFromSavedArtistsEvent event, Emitter<SavedArtistsState> emit) async {
    try {
      await _dbRepository.removeFromSavedArtists(event.artistId);
      // Emit update state so listeners (like Option Menu) update
      emit(IsArtistSavedState(isSaved: false, artistId: event.artistId));
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    }
  }

  void _getSavedArtists(
      GetSavedArtistsEvent event, Emitter<SavedArtistsState> emit) {
    emit(LoadingStateSavedArtists());
    try {
      final artistsStream = _dbRepository.getSavedArtists();
      emit(SavedArtistsDataState(artists: artistsStream));
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateSavedArtists(errorMessage: e.toString()));
    }
  }
}

