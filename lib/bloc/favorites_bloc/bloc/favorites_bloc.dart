import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final DbRepository _dbRepository;

  FavoritesBloc(this._dbRepository) : super(FavoritesInitial()) {
    on<AddToFavoritesEvent>(_addToFavorites);
    on<IsFavoritesEvent>(_checkIfFavorite);
    on<RemoveFromFavoritesEvent>(_removeFromFavorites);
  }

  Future<void> _addToFavorites(
      AddToFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(LoadingStateFavorites());
    try {
      await _dbRepository.addToFavorites(event.song);
      emit(IsFavoritesState(isFavorites: true));
    } catch (e) {
      emit(ErrorStateFavorites(errorMessage: e.toString()));
    }
  }

  Future<void> _checkIfFavorite(
      IsFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      final isFav = await _dbRepository.getIsFavorites(event.vId);
      emit(IsFavoritesState(isFavorites: isFav));
    } catch (e) {
      emit(ErrorStateFavorites(errorMessage: e.toString()));
    }
  }

  Future<void> _removeFromFavorites(
      RemoveFromFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(LoadingStateFavorites());
    try {
      await _dbRepository.removeFromFavorites(event.vId);
      emit(IsFavoritesState(isFavorites: false));
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateFavorites(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateFavorites(errorMessage: e.toString()));
    }
  }
}
