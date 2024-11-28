import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/helper_function/recent_tab/recentplaylist.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'recentplayed_event.dart';
part 'recentplayed_state.dart';

class RecentplayedBloc extends Bloc<RecentplayedEvent, RecentplayedState> {
  final DbRepository _dbRepository;
  List<Songmodel> _recentPlayed = [];
  RecentplayedBloc(this._dbRepository) : super(RecentplayedInitial()) {
    on<AddRecentplayedSongEvent>(_addRecentPlayed);
    on<GetRecentPlayedEvent>(_recentPlayedSongList);
  }
  Future<void> _addRecentPlayed(
      AddRecentplayedSongEvent event, Emitter<RecentplayedState> emit) async {
    // _recentPlayed = event.recentSongs;
    try {
      await _dbRepository.addToRecentPlayedCollection(event.song);
      _recentPlayed = updateRecentPlayedList(_recentPlayed, event.song);
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

  void _recentPlayedSongList(
      GetRecentPlayedEvent event, Emitter<RecentplayedState> emit) {
    emit(RecentPlayedSongsState(
        recentPlayedList: _recentPlayed.reversed.toList()));
  }
}
