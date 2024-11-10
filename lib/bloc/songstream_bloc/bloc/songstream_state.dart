part of 'songstream_bloc.dart';

sealed class SongstreamState {}

class SongstreamInitial extends SongstreamState {}

class LoadingState extends SongstreamState {
  final Songmodel songData;

  LoadingState({required this.songData});
}

class StreamSongState extends SongstreamState {}

class PlayingState extends SongstreamState {
  final bool isLoop;
  final Songmodel songData;

  PlayingState({
    required this.songData,
    this.isLoop = false,
  });

  PlayingState copyWith({
    bool? isLoop,
    Songmodel? songData,
  }) {
    return PlayingState(
      isLoop: isLoop ?? this.isLoop,
      songData: songData ?? this.songData,
    );
  }
}

class PausedState extends SongstreamState {
  final Songmodel songData;
  final bool isLoop;

  PausedState({
    required this.songData,
    this.isLoop = false,
  });

  PausedState copyWith({
    bool? isLoop,
    Songmodel? songData,
  }) {
    return PausedState(
      isLoop: isLoop ?? this.isLoop,
      songData: songData ?? this.songData,
    );
  }
}

class ErrorState extends SongstreamState {
  final String errorMessage;
  ErrorState({required this.errorMessage});
}

class CloseMiniPlayerState extends SongstreamState {}
