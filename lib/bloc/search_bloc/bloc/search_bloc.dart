import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Repository _repository;
  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SeachSongEvent>(_searchSong);
    on<Testing>(_testing);
  }
  Future<void> _searchSong(
      SeachSongEvent event, Emitter<SearchState> emit) async {
    emit(LoadingState());
    try {
      final songsList = await _repository.searchSongs(event.inputText);
      emit(SearchedSongsState(searchedSongs: songsList));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

  //testing
  Future<void> _testing(Testing event, Emitter<SearchState> emit) async {
    await _repository.testing();
  }
}
