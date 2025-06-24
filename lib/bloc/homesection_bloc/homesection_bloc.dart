import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/THINK_repo/THINK_repo.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:nex_music/secrets/think_key.dart';

part 'homesection_event.dart';
part 'homesection_state.dart';

class HomesectionBloc extends Bloc<HomesectionEvent, HomesectionState> {
  final Repository repository;
  final ThinkRepo _thinkRepo;
  final HiveDataBaseSingleton _hiveDataBaseSingleton;

  HomesectionBloc(this.repository, this._thinkRepo, this._hiveDataBaseSingleton)
      : super(HomesectionInitial()) {
    on<GetHomeSectonDataEvent>(_getHomeSectionData);
  }
  Future<void> _getHomeSectionData(
      GetHomeSectonDataEvent event, Emitter<HomesectionState> emit) async {
    emit(LoadingState());
    try {
      //
      String inputPrompt = DEFAULT_PROMPT;
      if (_hiveDataBaseSingleton.recommendationStatus) {
        inputPrompt = await _thinkRepo.getTHINKInputPrompt;
      }
      final homeSectionData = await repository.homeScreenSongsList(inputPrompt);
      final playlistsSet = homeSectionData.playlist.toSet();
      emit(
        HomeSectionState(
            quickPicks: homeSectionData.quickPicks,
            playlist: playlistsSet.toList()),
      );
    } catch (e) {
      emit(
        ErrorState(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
