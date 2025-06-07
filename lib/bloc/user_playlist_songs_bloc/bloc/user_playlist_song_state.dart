part of 'user_playlist_song_bloc.dart';

sealed class UserPlaylistSongState {}

final class UserPlaylistSongInitial extends UserPlaylistSongState {}

final class UserPlaylistSongLoadingState extends UserPlaylistSongState {}

final class UserPlaylistSongErrorState extends UserPlaylistSongState {
  final String errorMessage;

  UserPlaylistSongErrorState({required this.errorMessage});
}

final class UserPlaylistSongSongsDataState extends UserPlaylistSongState {
  final Stream<List<Songmodel>> data;

  UserPlaylistSongSongsDataState({required this.data});
}
