part of 'playlist_bloc.dart';

sealed class PlaylistState {}

final class PlaylistInitial extends PlaylistState {}

final class LoadingState extends PlaylistState {}

final class ErrorState extends PlaylistState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class PlaylistDataState extends PlaylistState {
  final List<Songmodel> playlistSongs;

  PlaylistDataState({
    required this.playlistSongs,
  });
}
