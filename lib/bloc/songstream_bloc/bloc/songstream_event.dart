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

final class SetSongDataToNullEvent extends SongstreamEvent {}

final class SetVolumeEvent extends SongstreamEvent {
  final double volume;

  SetVolumeEvent({required this.volume});
}

final class StartRadioEvent extends SongstreamEvent {
  final String videoId;

  StartRadioEvent({required this.videoId});
}

final class AddRadioSongsToPlaylistEvent extends SongstreamEvent {
  final List<Songmodel> radioSongs;

  AddRadioSongsToPlaylistEvent({required this.radioSongs});
}

final class PlayIndividualSongEvent extends SongstreamEvent {
  final Songmodel songData;
  final int songIndex;

  PlayIndividualSongEvent({
    required this.songData,
    required this.songIndex,
  });
}

final class RemoveFromPlaylistEvent extends SongstreamEvent {
  final String videoId;

  RemoveFromPlaylistEvent({required this.videoId});
}

final class GetUpcomingSongsEvent extends SongstreamEvent {}

final class ShouldShowStartRadioEvent extends SongstreamEvent {}

final class GetUpcomingSongsStateEvent extends SongstreamEvent {}

// Event to play a song from a playlist/album context
// This keeps the playlist songs in the Up Next queue instead of radio songs
final class PlaySongFromPlaylistEvent extends SongstreamEvent {
  final Songmodel songData;
  final int songIndex;
  final List<Songmodel> playlistSongs;

  PlaySongFromPlaylistEvent({
    required this.songData,
    required this.songIndex,
    required this.playlistSongs,
  });
}
