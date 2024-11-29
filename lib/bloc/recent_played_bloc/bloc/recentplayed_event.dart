part of 'recentplayed_bloc.dart';

sealed class RecentplayedEvent extends Equatable {}

final class GetRecentPlayedEvent extends RecentplayedEvent {
  @override
  List<Object?> get props => [];
}
