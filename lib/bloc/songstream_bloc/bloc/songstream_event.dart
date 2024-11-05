part of 'songstream_bloc.dart';

sealed class SongstreamEvent {}

class GetSongStreamEvent extends SongstreamEvent {
  final Songmodel songData;
  GetSongStreamEvent({required this.songData});
}

class PlayPauseEvent extends SongstreamEvent {}
