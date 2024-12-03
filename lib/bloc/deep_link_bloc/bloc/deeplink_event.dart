part of 'deeplink_bloc.dart';

sealed class DeeplinkEvent extends Equatable {}

final class GetDeeplinkSongDataEvent extends DeeplinkEvent {
  final String songId;

  GetDeeplinkSongDataEvent({required this.songId});

  @override
  List<Object?> get props => [songId];
}
