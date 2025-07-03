import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'search_album_event.dart';
part 'search_album_state.dart';

class SearchAlbumBloc extends Bloc<SearchAlbumEvent, SearchAlbumState> {
  final Repository _repository;

  SearchAlbumBloc(this._repository) : super(SearchAlbumInitial()) {
    on<SetStateToInitialSearchAlbumBlocEvent>(_setStateToInitial);
    on<SearchAlbumsEvent>(_searchAlbums);
  }

  void _setStateToInitial(SetStateToInitialSearchAlbumBlocEvent event,
      Emitter<SearchAlbumState> emit) {
    emit(SearchAlbumInitial());
  }

  Future<void> _searchAlbums(
      SearchAlbumsEvent event, Emitter<SearchAlbumState> emit) async {
    emit(LoadingState());
    try {
      final albumsData = await _repository.searchAlbums(event.inputText);
      emit(SearchedAlbumsDataState(albums: albumsData));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
