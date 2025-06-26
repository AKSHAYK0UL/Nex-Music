import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/secrets/THINK_repo/THINK_repo.dart';

part 'think_event.dart';
part 'think_state.dart';

class ThinkBloc extends Bloc<ThinkEvent, ThinkState> {
  final ThinkRepo _thinkRepo;

  ThinkBloc(this._thinkRepo) : super(ThinkInitial()) {
    on<UpdateTHINKRecommendationEvent>(_updateTHINKRecommendation);
    on<THINKRecommendationInitialDataEvent>(_initialTHINKData);
  }

  Future<void> _initialTHINKData(THINKRecommendationInitialDataEvent event,
      Emitter<ThinkState> emit) async {
    try {
      await _thinkRepo.saveTHINKInitialData();
    } on FirebaseException catch (e) {
      emit(ThinkErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(ThinkErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _updateTHINKRecommendation(
      UpdateTHINKRecommendationEvent event, Emitter<ThinkState> emit) async {
    try {
      await _thinkRepo.saveTHINKRecommendation();
    } on FirebaseException catch (e) {
      emit(ThinkErrorState(errorMessage: e.toString()));
    } catch (e) {
      emit(ThinkErrorState(errorMessage: e.toString()));
    }
  }
}
