part of 'deeplink_bloc.dart';

sealed class DeeplinkState extends Equatable {}

final class DeeplinkInitial extends DeeplinkState {
  @override
  List<Object?> get props => [];
}

final class LoadingState extends DeeplinkState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends DeeplinkState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
  @override
  List<Object?> get props => [];
}

final class DeeplinkSongDataState extends DeeplinkState {
  final Songmodel songData;

  DeeplinkSongDataState({required this.songData});

  @override
  List<Object?> get props => [songData];
}
