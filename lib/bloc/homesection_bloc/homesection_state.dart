part of 'homesection_bloc.dart';

sealed class HomesectionState {}

final class HomesectionInitial extends HomesectionState {}

final class LoadingState extends HomesectionState {}

final class ErrorState extends HomesectionState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class HomeSectionState extends HomesectionState {
  final List<Songmodel> quickPicks;
  final List<PlayListmodel> playlist;
  HomeSectionState({required this.quickPicks, required this.playlist});
}
