part of 'songstream_bloc.dart';

sealed class SongstreamEvent {}

final class GetSongStreamUrlEvent extends SongstreamEvent {
  final String songUrl;

  GetSongStreamUrlEvent({required this.songUrl});
}
