part of 'favorites_bloc.dart';

sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class LoadingStateFavorites extends FavoritesState {}

final class ErrorStateFavorites extends FavoritesState {
  final String errorMessage;

  ErrorStateFavorites({required this.errorMessage});
}

final class IsFavoritesState extends FavoritesState {
  final bool isFavorites;

  IsFavoritesState({required this.isFavorites});
}
