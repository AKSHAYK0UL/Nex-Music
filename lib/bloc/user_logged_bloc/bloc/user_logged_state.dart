part of 'user_logged_bloc.dart';

sealed class UserLoggedState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UserLoggedInitial extends UserLoggedState {}

final class LoggedInState extends UserLoggedState {}

final class LoadingState extends UserLoggedState {}

final class ErrorState extends UserLoggedState {
  final String errorMessage;

  ErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
