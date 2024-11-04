part of 'playlist_bloc.dart';

sealed class PlaylistEvent {}

final class GetPlaylistEvent extends PlaylistEvent {
  final String playlistId;

  GetPlaylistEvent({required this.playlistId});
}

final class LoadMoreSongsEvent extends PlaylistEvent {
  final String playlistId;

  LoadMoreSongsEvent({required this.playlistId});
}
