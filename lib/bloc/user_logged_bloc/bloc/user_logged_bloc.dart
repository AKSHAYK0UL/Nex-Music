import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_logged_event.dart';
part 'user_logged_state.dart';

class UserLoggedBloc extends Bloc<UserLoggedEvent, UserLoggedState> {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _authSubscription;

  UserLoggedBloc(this._firebaseAuth) : super(UserLoggedInitial()) {
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        add(UserLoggedInDetected());
      } else {
        add(UserLoggedOutDetected());
      }
    });

    on<UserLoggedInDetected>(
        (UserLoggedInDetected event, Emitter<UserLoggedState> emit) =>
            emit(LoggedInState()));
    on<UserLoggedOutDetected>(
        (UserLoggedOutDetected event, Emitter<UserLoggedState> emit) =>
            emit(UserLoggedInitial()));
    on<UserErrorDetected>(
        (UserErrorDetected event, Emitter<UserLoggedState> emit) =>
            emit(ErrorState(errorMessage: event.errorMessage)));
  }

  @override
  Future<void> close() async {
    _authSubscription.cancel();
    return super.close();
  }
}
