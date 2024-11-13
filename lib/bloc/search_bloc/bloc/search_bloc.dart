import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Repository _repository;
  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchSongSuggestionEvent>(_searchSuggestion);
    on<SeachSongEvent>(_searchSong);
  }

//provide search suggestion
  Future<void> _searchSuggestion(
      SearchSongSuggestionEvent event, Emitter<SearchState> emit) async {
    emit(LoadingState());
    try {
      final suggestionList =
          await _repository.searchSuggetion(event.inputQuery);
      emit(SearchSuggestionResultState(searchSuggestions: suggestionList));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

//search song
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
}
