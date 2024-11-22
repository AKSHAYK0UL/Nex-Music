part of 'search_bloc.dart';

sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class LoadingState extends SearchState {}

final class ErrorState extends SearchState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class SearchSuggestionResultState extends SearchState {
  List<String> searchSuggestions = [];
  SearchSuggestionResultState({required this.searchSuggestions});
}

final class LoadedRecentSearchState extends SearchState {
  List<String> recentSerach = [];
  LoadedRecentSearchState({required this.recentSerach});
}
