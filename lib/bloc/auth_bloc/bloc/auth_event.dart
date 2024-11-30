part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {}

final class GoogleSignInEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class SignOutEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}
