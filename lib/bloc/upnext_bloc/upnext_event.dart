part of 'upnext_bloc.dart';

sealed class UpnextEvent {}

final class LoadUpcomingSongsEvent extends UpnextEvent {}

final class StartRadioFromUpnextEvent extends UpnextEvent {
  final String videoId;

  StartRadioFromUpnextEvent({required this.videoId});
}

final class RemoveSongFromUpnextEvent extends UpnextEvent {
  final String videoId;

  RemoveSongFromUpnextEvent({required this.videoId});
}

final class PlaySongFromUpnextEvent extends UpnextEvent {
  final Songmodel songData;

  PlaySongFromUpnextEvent({required this.songData});
}

final class RefreshUpnextEvent extends UpnextEvent {}

final class ClearUpnextEvent extends UpnextEvent {}
