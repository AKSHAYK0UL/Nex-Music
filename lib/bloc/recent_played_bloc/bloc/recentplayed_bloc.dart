import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';

part 'recentplayed_event.dart';
part 'recentplayed_state.dart';

class RecentplayedBloc extends Bloc<RecentplayedEvent, RecentplayedState> {
  List<Songmodel> _recentPlayed = [];
  RecentplayedBloc() : super(RecentplayedInitial()) {
    on<AddRecentplayedSongEvent>(_addRecentPlayed);
    on<GetRecentPlayedEvent>(_recentPlayedSongList);
  }
  void _addRecentPlayed(
      AddRecentplayedSongEvent event, Emitter<RecentplayedState> emit) {
    _recentPlayed = event.recentSongs;
  }

  void _recentPlayedSongList(
      GetRecentPlayedEvent event, Emitter<RecentplayedState> emit) {
    emit(RecentPlayedSongsState(
        recentPlayedList: _recentPlayed.reversed.toList()));
  }
}
