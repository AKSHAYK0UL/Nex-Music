import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'song_event.dart';
part 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final Repository _repository;
  SongBloc(this._repository) : super(SongInitial()) {
    on<SeachInSongEvent>(_searchInSong);
  }
  //search In song
  Future<void> _searchInSong(
      SeachInSongEvent event, Emitter<SongState> emit) async {
    emit(LoadingState());
    try {
      final songsResult = await _repository.searchSong(event.inputText);
      emit(SongsResultState(searchedSongs: songsResult));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
