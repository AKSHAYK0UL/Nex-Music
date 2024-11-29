part of 'song_dialog_bloc.dart';

sealed class SongDialogEvent extends Equatable {}

final class RemoveFromRecentlyPlayedEvent extends SongDialogEvent {
  final String vId;
  RemoveFromRecentlyPlayedEvent({required this.vId});

  @override
  List<Object?> get props => [vId];
}
