import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Repository _repository;
  final DbRepository _dbRepository;

  SearchBloc(this._repository, this._dbRepository) : super(SearchInitial()) {
    on<SearchSongSuggestionEvent>(_searchSuggestion);
    on<AddRecentSearchEvent>(_addRecentSearch);
    on<LoadRecentSearchEvent>(_loadRecentSearch);
    on<DeleteRecentSearchEvent>(_deleteRecentSearch);
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
  Future<void> _addRecentSearch(AddRecentSearchEvent event, Emitter<SearchState> emit) async {
    try {
      await _dbRepository.addSearchQuery(event.search);
      // The stream will automatically update the UI
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

//load the recent search history
  void _loadRecentSearch(
      LoadRecentSearchEvent event, Emitter<SearchState> emit) {
    emit(LoadingState());
    try {
      final searchHistoryStream = _dbRepository.getSearchHistory();
      emit(LoadedRecentSearchState(searchHistoryStream: searchHistoryStream));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

//delete a search query from history
  Future<void> _deleteRecentSearch(DeleteRecentSearchEvent event, Emitter<SearchState> emit) async {
    try {
      await _dbRepository.deleteSearchQuery(event.search);
      // The stream will automatically update the UI
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
