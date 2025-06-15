part of 'offline_songs_bloc.dart';

sealed class OfflineSongsEvent {}

final class LoadOfflineSongsEvent extends OfflineSongsEvent {}

final class DeleteDownloadedSongEvent extends OfflineSongsEvent {
  final Songmodel songData;

  DeleteDownloadedSongEvent({required this.songData});
}
