part of 'download_bloc.dart';

sealed class DownloadEvent {}

final class DownloadSongEvent extends DownloadEvent {
  final Songmodel songData;

  DownloadSongEvent({required this.songData});
}
