part of 'favorites_bloc.dart';

sealed class FavoritesEvent {}

final class AddToFavoritesEvent extends FavoritesEvent {
  final Songmodel song;

  AddToFavoritesEvent({required this.song});
}

final class IsFavoritesEvent extends FavoritesEvent {
  final String vId;

  IsFavoritesEvent({required this.vId});
}

final class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String vId;
  RemoveFromFavoritesEvent({required this.vId});
}
