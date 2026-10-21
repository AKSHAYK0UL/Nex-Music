part of 'lyrics_bloc.dart';

sealed class LyricsState extends Equatable {
  const LyricsState();

  @override
  List<Object?> get props => [];
}

final class LyricsInitialState extends LyricsState {}

final class LyricsLoadingState extends LyricsState {
  final Songmodel songData;

  const LyricsLoadingState({required this.songData});

  @override
  List<Object?> get props => [songData];
}

final class LyricsLoadedState extends LyricsState {
  final Songmodel songData;
  final LyricModel lyricModel;
  final bool isSyncEnabled;

  const LyricsLoadedState({
    required this.songData,
    required this.lyricModel,
    this.isSyncEnabled = true,
  });

  LyricsLoadedState copyWith({
    Songmodel? songData,
    LyricModel? lyricModel,
    bool? isSyncEnabled,
  }) {
    return LyricsLoadedState(
      songData: songData ?? this.songData,
      lyricModel: lyricModel ?? this.lyricModel,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
    );
  }

  @override
  List<Object?> get props => [songData, lyricModel, isSyncEnabled];
}

final class LyricsNotFoundState extends LyricsState {
  final Songmodel songData;

  const LyricsNotFoundState({required this.songData});

  @override
  List<Object?> get props => [songData];
}

final class LyricsErrorState extends LyricsState {
  final String errorMessage;
  final Songmodel songData;

  const LyricsErrorState({
    required this.errorMessage,
    required this.songData,
  });

  @override
  List<Object?> get props => [errorMessage, songData];
}
