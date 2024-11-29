part of 'song_dialog_bloc.dart';

sealed class SongDialogState extends Equatable {}

final class SongDialogInitial extends SongDialogState {
  @override
  List<Object?> get props => [];
}

final class LoadingState extends SongDialogState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends SongDialogState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}
