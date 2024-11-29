import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'recentplayed_event.dart';
part 'recentplayed_state.dart';

class RecentplayedBloc extends Bloc<RecentplayedEvent, RecentplayedState> {
  final DbRepository _dbRepository;
  RecentplayedBloc(this._dbRepository) : super(RecentplayedInitial()) {
    on<GetRecentPlayedEvent>(_recentPlayedSongList);
  }

  void _recentPlayedSongList(
      GetRecentPlayedEvent event, Emitter<RecentplayedState> emit) {
    emit(LoadingState());
    try {
      final recentPlayedStream = _dbRepository.getRecentPlayed();
      emit(RecentPlayedSongsState(recentPlayedStream: recentPlayedStream));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
