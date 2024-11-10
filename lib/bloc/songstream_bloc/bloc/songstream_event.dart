part of 'songstream_bloc.dart';

sealed class SongstreamEvent {}

class GetSongStreamEvent extends SongstreamEvent {
  final Songmodel songData;
  GetSongStreamEvent({required this.songData});
}

class GetSongUrlOnShuffleEvent extends SongstreamEvent {
  final Songmodel songData;
  GetSongUrlOnShuffleEvent({required this.songData});
}

class PlayPauseEvent extends SongstreamEvent {}

class CloseMiniPlayerEvent extends SongstreamEvent {}

class SongCompletedEvent extends SongstreamEvent {}

class PauseEvent extends SongstreamEvent {}

class PlayEvent extends SongstreamEvent {}

class SeekToEvent extends SongstreamEvent {
  final Duration position;
  SeekToEvent({required this.position});
}

class LoopEvent extends SongstreamEvent {}

final class GetSongPlaylistEvent extends SongstreamEvent {
  final List<Songmodel> songlist;

  GetSongPlaylistEvent({required this.songlist});
}
