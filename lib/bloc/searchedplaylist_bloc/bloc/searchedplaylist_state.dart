part of 'searchedplaylist_bloc.dart';

sealed class SearchedplaylistState {}

final class SearchedplaylistInitial extends SearchedplaylistState {}

final class LoadingState extends SearchedplaylistState {}

final class ErrorState extends SearchedplaylistState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class PlaylistDataState extends SearchedplaylistState {
  List<PlayListmodel> playlist = [];
  PlaylistDataState({required this.playlist});
}
