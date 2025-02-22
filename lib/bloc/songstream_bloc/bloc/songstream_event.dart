part of 'songstream_bloc.dart';

sealed class SongstreamEvent {}

final class GetSongStreamEvent extends SongstreamEvent {
  final Songmodel songData;
  final int songIndex;
  GetSongStreamEvent({
    required this.songData,
    required this.songIndex,
  });
}

final class GetSongUrlOnShuffleEvent extends SongstreamEvent {
  final Songmodel songData;
  GetSongUrlOnShuffleEvent({required this.songData});
}

final class PlayPauseEvent extends SongstreamEvent {}

final class CloseMiniPlayerEvent extends SongstreamEvent {}

final class SongCompletedEvent extends SongstreamEvent {}

final class PauseEvent extends SongstreamEvent {}

final class PlayEvent extends SongstreamEvent {}

final class UpdateUIEvent extends SongstreamEvent {}

final class SeekToEvent extends SongstreamEvent {
  final Duration position;
  SeekToEvent({required this.position});
}

final class LoopEvent extends SongstreamEvent {}

final class StoreQuickPicksSongsEvent extends SongstreamEvent {
  List<Songmodel> quickPicks = [];
  StoreQuickPicksSongsEvent({required this.quickPicks});
}

final class GetSongPlaylistEvent extends SongstreamEvent {
  final List<Songmodel> songlist;

  GetSongPlaylistEvent({required this.songlist});
}

final class ResetPlaylistEvent extends SongstreamEvent {}

final class CleanPlaylistEvent extends SongstreamEvent {}

final class LoadingEvent extends SongstreamEvent {}

final class PlayNextSongEvent extends SongstreamEvent {}

final class PlayPreviousSongEvent extends SongstreamEvent {}

final class MuteEvent extends SongstreamEvent {}

final class DisposeAudioPlayerEvent extends SongstreamEvent {}

final class AddToPlayNextEvent extends SongstreamEvent {
  final Songmodel songData;

  AddToPlayNextEvent({required this.songData});
}
