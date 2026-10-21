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
