part of 'user_playlist_bloc.dart';

sealed class UserPlaylistEvent {}

final class CreatePlaylistEvent extends UserPlaylistEvent {
  final String playlistName;

  CreatePlaylistEvent({required this.playlistName});
}

final class GetUserPlaylistsEvent extends UserPlaylistEvent {}

final class AddSongToUserPlaylistEvent extends UserPlaylistEvent {
  final String playlistName;
  final Songmodel songData;

  AddSongToUserPlaylistEvent(
      {required this.playlistName, required this.songData});
}

final class DeleteUserPlaylistEvent extends UserPlaylistEvent {
  final String playlistName;

  DeleteUserPlaylistEvent({required this.playlistName});
}

final class DeleteSongUserPlaylistEvent extends UserPlaylistEvent {
  final String playlistName;
  final String vId;

  DeleteSongUserPlaylistEvent({required this.playlistName, required this.vId});
}
