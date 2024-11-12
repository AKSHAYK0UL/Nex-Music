part of 'search_bloc.dart';

sealed class SearchEvent {}

final class SeachSongEvent extends SearchEvent {
  final String inputText;

  SeachSongEvent({required this.inputText});
}

final class Testing extends SearchEvent {}
