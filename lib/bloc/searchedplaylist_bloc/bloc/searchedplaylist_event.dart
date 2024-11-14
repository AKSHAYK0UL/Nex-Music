part of 'searchedplaylist_bloc.dart';

sealed class SearchedplaylistEvent {}

final class SetStateToInitialEvent extends SearchedplaylistEvent {}

final class SearchInPlaylistEvent extends SearchedplaylistEvent {
  final String inputText;

  SearchInPlaylistEvent({required this.inputText});
}
