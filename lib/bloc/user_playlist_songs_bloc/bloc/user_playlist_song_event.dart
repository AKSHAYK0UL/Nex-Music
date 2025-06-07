part of 'user_playlist_song_bloc.dart';

sealed class UserPlaylistSongEvent {}

final class GetuserPlaylistSongsEvent extends UserPlaylistSongEvent {
  final String playlistName;

  GetuserPlaylistSongsEvent({required this.playlistName});
}
