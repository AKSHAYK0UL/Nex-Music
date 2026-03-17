part of 'songstream_bloc.dart';

sealed class SongstreamState {}

class SongstreamInitial extends SongstreamState {}

class LoadingState extends SongstreamState {
  final Songmodel songData;
  final double volume;
  final bool isMuted;

  LoadingState({
    required this.songData,
    this.volume = 0.5,
    this.isMuted = false,
  });
}

class StreamSongState extends SongstreamState {}

class PlayingState extends SongstreamState {
  final Songmodel songData;
  final double volume;
  final bool isMuted;

  PlayingState({
    required this.songData,
    this.volume = 0.5,
    this.isMuted = false,
  });

  PlayingState copyWith({
    Songmodel? songData,
    double? volume,
    bool? isMuted,
  }) {
    return PlayingState(
      songData: songData ?? this.songData,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class PausedState extends SongstreamState {
  final Songmodel songData;
  final double volume;
  final bool isMuted;

  PausedState({
    required this.songData,
    this.volume = 0.5,
    this.isMuted = false,
  });

  PausedState copyWith({
    Songmodel? songData,
    double? volume,
    bool? isMuted,
  }) {
    return PausedState(
      songData: songData ?? this.songData,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class ErrorState extends SongstreamState {
  final String errorMessage;
  ErrorState({required this.errorMessage});
}

class CloseMiniPlayerState extends SongstreamState {}

class UpcomingSongsState extends SongstreamState {
  final List<Songmodel> upcomingSongs;
  final bool isLoading;
  final bool shouldShowStartRadio;

  UpcomingSongsState({
    required this.upcomingSongs,
    required this.isLoading,
    required this.shouldShowStartRadio,
  });
}
