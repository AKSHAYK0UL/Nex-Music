part of 'user_logged_bloc.dart';

sealed class UserLoggedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UserLoggedInDetected extends UserLoggedEvent {}

final class UserLoggedOutDetected extends UserLoggedEvent {}

final class UserErrorDetected extends UserLoggedEvent {
  final String errorMessage;

  UserErrorDetected({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
