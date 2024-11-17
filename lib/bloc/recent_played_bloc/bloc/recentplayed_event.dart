part of 'recentplayed_bloc.dart';

sealed class RecentplayedEvent extends Equatable {}

final class AddRecentplayedSongEvent extends RecentplayedEvent {
  final List<Songmodel> recentSongs;

  AddRecentplayedSongEvent({required this.recentSongs});
  @override
  List<Object?> get props => [recentSongs];
}

final class GetRecentPlayedEvent extends RecentplayedEvent {
  @override
  List<Object?> get props => [];
}
