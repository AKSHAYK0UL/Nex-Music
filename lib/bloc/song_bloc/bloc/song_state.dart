part of 'song_bloc.dart';

sealed class SongState {}

final class SongInitial extends SongState {}

final class LoadingState extends SongState {
  final String query;

  LoadingState({required this.query});
}

final class ErrorState extends SongState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class SongsResultState extends SongState {
  final String query;
  final List<Songmodel> searchedSongs;

  SongsResultState({required this.searchedSongs, required this.query});
}
