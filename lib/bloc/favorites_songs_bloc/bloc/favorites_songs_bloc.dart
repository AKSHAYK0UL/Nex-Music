import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/model/songmodel.dart';

part 'favorites_songs_event.dart';
part 'favorites_songs_state.dart';

class FavoritesSongsBloc
    extends Bloc<FavoritesSongsEvent, FavoritesSongsState> {
  final DbRepository _dbRepository;

  FavoritesSongsBloc(this._dbRepository) : super(FavoritesSongsInitial()) {
    on<GetFavoritesEvent>(_getFavorites);
  }
  //
  void _getFavorites(
      GetFavoritesEvent event, Emitter<FavoritesSongsState> emit) {
    emit(LoadingStateFavoritesSongs());
    try {
      final favSongs = _dbRepository.getFavorites();
      emit(FavortiesSongsDataState(songs: favSongs));
    } on FirebaseAuthException catch (e) {
      emit(ErrorStateFavoritesSongs(errorMessage: e.toString()));
    } catch (e) {
      emit(ErrorStateFavoritesSongs(errorMessage: e.toString()));
    }
  }
}
