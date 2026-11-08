part of 'playlist_bloc.dart';

sealed class PlaylistEvent {}

final class GetPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final String playlistName;
  final bool isAlbum;

  GetPlaylistEvent({
    required this.playlistId,
    this.playlistName = '',
    this.isAlbum = false,
  });
}

final class LoadMoreSongsEvent extends PlaylistEvent {
  final String playlistId;
  final bool isAlbum;

  LoadMoreSongsEvent({
    required this.playlistId,
    this.isAlbum = false,
  });
}
