part of 'search_bloc.dart';

sealed class SearchEvent {}

final class SearchSongSuggestionEvent extends SearchEvent {
  final String inputQuery;

  SearchSongSuggestionEvent({required this.inputQuery});
}
