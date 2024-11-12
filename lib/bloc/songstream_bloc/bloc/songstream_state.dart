part of 'songstream_bloc.dart';

sealed class SongstreamState {}

class SongstreamInitial extends SongstreamState {}

class LoadingState extends SongstreamState {
  final Songmodel songData;

  LoadingState({required this.songData});
}

class StreamSongState extends SongstreamState {}

class PlayingState extends SongstreamState {
  final Songmodel songData;

  PlayingState({
    required this.songData,
  });

  PlayingState copyWith({
    Songmodel? songData,
  }) {
    return PlayingState(
      songData: songData ?? this.songData,
    );
  }
}

class PausedState extends SongstreamState {
  final Songmodel songData;

  PausedState({
    required this.songData,
  });

  PausedState copyWith({
    Songmodel? songData,
  }) {
    return PausedState(
      songData: songData ?? this.songData,
    );
  }
}

class ErrorState extends SongstreamState {
  final String errorMessage;
  ErrorState({required this.errorMessage});
}

class CloseMiniPlayerState extends SongstreamState {}
