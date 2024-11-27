import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/helper_function/updaterecentsearch.dart/updaterecentsearch.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Repository _repository;
  List<String> _recentSearchList = [];

  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchSongSuggestionEvent>(_searchSuggestion);
    on<AddRecentSearchEvent>(_addRecentSearch);
    on<LoadRecentSearchEvent>(_loadRecentSearch);
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

//add search query to recent search list
  void _addRecentSearch(AddRecentSearchEvent event, Emitter<SearchState> emit) {
    _recentSearchList = updateRecentSearch(event.search, _recentSearchList);
    emit(LoadedRecentSearchState(recentSerach: _recentSearchList));
  }

//load the recent search history
  void _loadRecentSearch(
      LoadRecentSearchEvent event, Emitter<SearchState> emit) {
    emit(LoadedRecentSearchState(recentSerach: _recentSearchList));
  }
}
