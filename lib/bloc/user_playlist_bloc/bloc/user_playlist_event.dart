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

// final class GetuserPlaylistSongsEvent extends UserPlaylistEvent {
//   final String playlistName;

//   GetuserPlaylistSongsEvent({required this.playlistName});
// }
