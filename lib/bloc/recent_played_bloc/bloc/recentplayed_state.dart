part of 'recentplayed_bloc.dart';

sealed class RecentplayedState extends Equatable {}

final class RecentplayedInitial extends RecentplayedState {
  @override
  List<Object?> get props => [];
}

final class LoadingState extends RecentplayedState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends RecentplayedState {
  final String errorMessage;
  ErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ignore: must_be_immutable
final class RecentPlayedSongsState extends RecentplayedState {
  Stream<List<Songmodel>> recentPlayedStream;
  RecentPlayedSongsState({required this.recentPlayedStream});

  @override
  List<Object?> get props => [recentPlayedStream];
}
