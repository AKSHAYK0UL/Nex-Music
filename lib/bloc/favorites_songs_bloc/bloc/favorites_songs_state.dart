part of 'favorites_songs_bloc.dart';

sealed class FavoritesSongsState {}

final class FavoritesSongsInitial extends FavoritesSongsState {}

final class LoadingStateFavoritesSongs extends FavoritesSongsState {}

final class ErrorStateFavoritesSongs extends FavoritesSongsState {
  final String errorMessage;

  ErrorStateFavoritesSongs({required this.errorMessage});
}

final class FavortiesSongsDataState extends FavoritesSongsState {
  Stream<List<Songmodel>> songs;
  FavortiesSongsDataState({required this.songs});
}
