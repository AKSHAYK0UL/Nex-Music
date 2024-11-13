part of 'song_bloc.dart';

sealed class SongEvent {}

final class SeachInSongEvent extends SongEvent {
  final String inputText;

  SeachInSongEvent({required this.inputText});
}
