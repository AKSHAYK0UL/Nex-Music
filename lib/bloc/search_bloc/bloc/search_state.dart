part of 'search_bloc.dart';

sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class LoadingState extends SearchState {}

final class ErrorState extends SearchState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class SearchedSongsState extends SearchState {
  final List<Songmodel> searchedSongs;

  SearchedSongsState({required this.searchedSongs});
}
