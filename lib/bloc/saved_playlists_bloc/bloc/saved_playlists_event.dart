part of 'saved_playlists_bloc.dart';

sealed class SavedPlaylistsEvent {}

final class AddToSavedPlaylistsEvent extends SavedPlaylistsEvent {
  final SavedPlaylistModel playlist;

  AddToSavedPlaylistsEvent({required this.playlist});
}

final class IsPlaylistSavedEvent extends SavedPlaylistsEvent {
  final String playlistId;

  IsPlaylistSavedEvent({required this.playlistId});
}

final class RemoveFromSavedPlaylistsEvent extends SavedPlaylistsEvent {
  final String playlistId;
  RemoveFromSavedPlaylistsEvent({required this.playlistId});
}

final class GetSavedPlaylistsEvent extends SavedPlaylistsEvent {}
