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

  // Per-provider saved sync offsets (populated from storage on load/switch).
  final Duration ytSyncOffset;
  final Duration lrclibSyncOffset;

  const LyricsLoadedState({
    required this.songData,
    required this.lyricModel,
    this.isSyncEnabled = true,
    this.source = LyricsSource.ytMusic,
    this.ytLyrics,
    this.lrclibLyrics,
    this.ytSyncOffset = Duration.zero,
    this.lrclibSyncOffset = Duration.zero,
  });

  // Returns the active sync offset for the current [source].
  Duration get syncOffset =>
      source == LyricsSource.ytMusic ? ytSyncOffset : lrclibSyncOffset;

  LyricsLoadedState copyWith({
    Songmodel? songData,
    LyricModel? lyricModel,
    bool? isSyncEnabled,
    LyricsSource? source,
    LyricModel? ytLyrics,
    LyricModel? lrclibLyrics,
    Duration? ytSyncOffset,
    Duration? lrclibSyncOffset,
  }) {
    return LyricsLoadedState(
      songData: songData ?? this.songData,
      lyricModel: lyricModel ?? this.lyricModel,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
      source: source ?? this.source,
      ytLyrics: ytLyrics ?? this.ytLyrics,
      lrclibLyrics: lrclibLyrics ?? this.lrclibLyrics,
      ytSyncOffset: ytSyncOffset ?? this.ytSyncOffset,
      lrclibSyncOffset: lrclibSyncOffset ?? this.lrclibSyncOffset,
    );
  }

  // Whether the alternative source has lyrics available.
  bool get hasYtLyrics => ytLyrics != null && ytLyrics!.hasLyrics;
  bool get hasLrclibLyrics => lrclibLyrics != null && lrclibLyrics!.hasLyrics;

  @override
  List<Object?> get props => [
        songData,
        lyricModel,
        isSyncEnabled,
        source,
        ytLyrics,
        lrclibLyrics,
        ytSyncOffset,
        lrclibSyncOffset
      ];
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
