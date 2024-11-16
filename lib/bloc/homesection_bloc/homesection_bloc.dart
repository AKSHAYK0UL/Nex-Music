import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'homesection_event.dart';
part 'homesection_state.dart';

class HomesectionBloc extends Bloc<HomesectionEvent, HomesectionState> {
  final Repository repository;
  HomesectionBloc(this.repository) : super(HomesectionInitial()) {
    on<GetHomeSectonDataEvent>(_getHomeSectionData);
  }
  Future<void> _getHomeSectionData(
      GetHomeSectonDataEvent event, Emitter<HomesectionState> emit) async {
    emit(LoadingState());
    try {
      final homeSectionData = await repository.homeScreenSongsList();
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
