import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<GoogleSignInEvent>(_googleSignIn);
    on<SignOutEvent>(_signOut);
  }
  Future<void> _googleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      await _authRepository.googleSignIn();
      emit(SuccessState());
    } on FirebaseAuthException catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _signOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      await _authRepository.signOut();
      emit(SuccessState());
    } on FirebaseAuth catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
