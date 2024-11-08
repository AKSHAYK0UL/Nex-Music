part of 'songstream_bloc.dart';

sealed class SongstreamEvent {}

class GetSongStreamEvent extends SongstreamEvent {
  final Songmodel songData;
  GetSongStreamEvent({required this.songData});
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
