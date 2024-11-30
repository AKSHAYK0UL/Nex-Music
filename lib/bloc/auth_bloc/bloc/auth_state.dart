part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {}

final class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

final class LoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends AuthState {
  final String errorMessage;
  ErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

final class SuccessState extends AuthState {
  @override
  List<Object?> get props => [];
}
