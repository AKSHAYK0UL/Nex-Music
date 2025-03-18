import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';
import 'package:nex_music/core/services/hive_singleton.dart';

part 'quality_event.dart';
part 'quality_state.dart';

class QualityBloc extends Bloc<QualityEvent, QualityState> {
  final HiveDataBaseSingleton _dataBaseSingleton;
  QualityBloc(this._dataBaseSingleton) : super(QualityInitial()) {
    on<SaveQualityEvent>(save);
    on<GetQualityEvent>(getQuality);
  }

  Future<void> save(SaveQualityEvent event, Emitter<QualityState> emit) async {
    emit(LoadingState());
    try {
      await _dataBaseSingleton.save(event.hiveQuality);
      emit(SuccessState());
    } catch (e) {
      emit(ErrorState(errorMassage: e.toString()));
    }
  }

  Future<void> getQuality(
      GetQualityEvent event, Emitter<QualityState> emit) async {
    emit(LoadingState());
    try {
      final data = await _dataBaseSingleton.getData;
      emit(QualityDataState(data: data));
    } catch (e) {
      emit(ErrorState(errorMassage: e.toString()));
    }
  }
}
