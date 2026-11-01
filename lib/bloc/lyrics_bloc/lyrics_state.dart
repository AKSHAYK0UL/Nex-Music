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

  // Which source the active [lyricModel] came from.
  final LyricsSource source;

  // Cached alternative source lyrics (null if not yet fetched / unavailable).
  final LyricModel? ytLyrics;
  final LyricModel? lrclibLyrics;

  const LyricsLoadedState({
    required this.songData,
    required this.lyricModel,
    this.isSyncEnabled = true,
    this.source = LyricsSource.ytMusic,
    this.ytLyrics,
    this.lrclibLyrics,
  });

  LyricsLoadedState copyWith({
    Songmodel? songData,
    LyricModel? lyricModel,
    bool? isSyncEnabled,
    LyricsSource? source,
    LyricModel? ytLyrics,
    LyricModel? lrclibLyrics,
  }) {
    return LyricsLoadedState(
      songData: songData ?? this.songData,
      lyricModel: lyricModel ?? this.lyricModel,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
      source: source ?? this.source,
      ytLyrics: ytLyrics ?? this.ytLyrics,
      lrclibLyrics: lrclibLyrics ?? this.lrclibLyrics,
    );
  }

  // Whether the alternative source has lyrics available.
  bool get hasYtLyrics => ytLyrics != null && ytLyrics!.hasLyrics;
  bool get hasLrclibLyrics => lrclibLyrics != null && lrclibLyrics!.hasLyrics;

  @override
  List<Object?> get props =>
      [songData, lyricModel, isSyncEnabled, source, ytLyrics, lrclibLyrics];
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
