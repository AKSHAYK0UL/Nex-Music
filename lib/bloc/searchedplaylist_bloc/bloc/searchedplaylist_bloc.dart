import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'searchedplaylist_event.dart';
part 'searchedplaylist_state.dart';

class SearchedplaylistBloc
    extends Bloc<SearchedplaylistEvent, SearchedplaylistState> {
  final Repository _repository;
  SearchedplaylistBloc(this._repository) : super(SearchedplaylistInitial()) {
    on<SearchInPlaylistEvent>(_searchPlaylist);
    on<SetStateToInitialEvent>(_setStateToInitial);
  }
  //set State to Initial
  void _setStateToInitial(
      SetStateToInitialEvent event, Emitter<SearchedplaylistState> emit) {
    emit(SearchedplaylistInitial());
  }

  Future<void> _searchPlaylist(
      SearchInPlaylistEvent event, Emitter<SearchedplaylistState> emit) async {
    emit(LoadingState());
    try {
      final playlist = await _repository.searchPlaylist(event.inputText);
      emit(PlaylistDataState(playlist: playlist));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
