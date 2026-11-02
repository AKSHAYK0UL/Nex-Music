part of 'lyrics_bloc.dart';

sealed class LyricsEvent extends Equatable {
  const LyricsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadLyricsEvent extends LyricsEvent {
  final Songmodel songData;
  final int? durationSeconds;

  const LoadLyricsEvent({
    required this.songData,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [songData, durationSeconds];
}

final class ToggleSyncLyricsEvent extends LyricsEvent {
  const ToggleSyncLyricsEvent();
}

// Switch the active lyrics source between YT Music and LRCLIB.
final class SwitchLyricsSourceEvent extends LyricsEvent {
  final LyricsSource source;
  const SwitchLyricsSourceEvent(this.source);

  @override
  List<Object?> get props => [source];
}

// save sync time config to Hive + Firestore for [songId] / [source].
final class UpdateLyricSyncOffsetEvent extends LyricsEvent {
  final String songId;
  final LyricsSource source;
  final Duration offset;

  const UpdateLyricSyncOffsetEvent({
    required this.songId,
    required this.source,
    required this.offset,
  });

  @override
  List<Object?> get props => [songId, source, offset];
}
