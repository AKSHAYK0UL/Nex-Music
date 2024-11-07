// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'songstream_bloc.dart';

sealed class SongstreamState {}

class SongstreamInitial extends SongstreamState {}

class LoadingState extends SongstreamState {}

class StreamSongState extends SongstreamState {}

class PlayingState extends SongstreamState {
  final Songmodel songData;
  PlayingState({
    required this.songData,
  });
}

class PausedState extends SongstreamState {
  final Songmodel songData;

  PausedState({
    required this.songData,
  });
}

class ErrorState extends SongstreamState {
  final String errorMessage;
  ErrorState({required this.errorMessage});
}

class CloseMiniPlayerState extends SongstreamState {}
