part of 'search_bloc.dart';

sealed class SearchEvent {}

final class SearchSongSuggestionEvent extends SearchEvent {
  final String inputQuery;

  SearchSongSuggestionEvent({required this.inputQuery});
}

final class AddRecentSearchEvent extends SearchEvent {
  final String search;

  AddRecentSearchEvent({required this.search});
}

final class LoadRecentSearchEvent extends SearchEvent {}
