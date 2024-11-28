part of 'recentplayed_bloc.dart';

sealed class RecentplayedEvent extends Equatable {}

final class AddRecentplayedSongEvent extends RecentplayedEvent {
  // final List<Songmodel> recentSongs;
  final Songmodel song;

  AddRecentplayedSongEvent({required this.song});
  @override
  List<Object?> get props => [song];
}

final class GetRecentPlayedEvent extends RecentplayedEvent {
  @override
  List<Object?> get props => [];
}
