import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'deeplink_event.dart';
part 'deeplink_state.dart';

class DeeplinkBloc extends Bloc<DeeplinkEvent, DeeplinkState> {
  final Repository _repository;

  DeeplinkBloc(this._repository) : super(DeeplinkInitial()) {
    on<GetDeeplinkSongDataEvent>(_playSongDeepLink);
  }
  //play song when using DeepLink
  Future<void> _playSongDeepLink(
      GetDeeplinkSongDataEvent event, Emitter<DeeplinkState> emit) async {
    emit(LoadingState());
    try {
      final songData = await _repository.getSongDataDeeplink(event.songId);
      emit(DeeplinkSongDataState(songData: songData));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
