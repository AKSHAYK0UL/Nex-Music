import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final HiveDataBaseSingleton _dbInstance;
  AuthBloc(this._authRepository, this._dbInstance) : super(AuthInitial()) {
    on<GoogleSignInEvent>(_googleSignIn);
    on<SignOutEvent>(_signOut);
  }

  Future<void> _googleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      await Future.wait([
        _dbInstance.save(HiveQuality(
            thumbnailQuality: Platform.isAndroid
                ? ThumbnailQuality.low
                : ThumbnailQuality.medium,
            audioQuality: AudioQuality.high)),
        _dbInstance.saveRecommendation(false),
      ]);
      // await _dbInstance.save(HiveQuality(
      //     thumbnailQuality: Platform.isAndroid
      //         ? ThumbnailQuality.low
      //         : ThumbnailQuality.medium,
      //     audioQuality: AudioQuality.high));

      if (Platform.isAndroid) {
        await _authRepository.googleSignIn();
      } else {
        await _authRepository.googleDesktopSignIn();
      }

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
