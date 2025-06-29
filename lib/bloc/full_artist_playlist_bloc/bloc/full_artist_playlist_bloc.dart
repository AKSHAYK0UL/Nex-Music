import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'full_artist_playlist_event.dart';
part 'full_artist_playlist_state.dart';

class FullArtistPlaylistBloc
    extends Bloc<FullArtistPlaylistEvent, FullArtistPlaylistState> {
  final Repository _repository;
  FullArtistPlaylistBloc(this._repository)
      : super(FullArtistPlaylistInitial()) {
    on<SetFullArtistPlaylistInitialEvent>(_setFullArtistPlaylistInitialState);
    on<GetFullArtistPlaylistEvent>(_getFullArtistPlaylist);
  }

  void _setFullArtistPlaylistInitialState(
      SetFullArtistPlaylistInitialEvent event,
      Emitter<FullArtistPlaylistState> emit) {
    emit(FullArtistPlaylistInitial());
  }

  Future<void> _getFullArtistPlaylist(GetFullArtistPlaylistEvent event,
      Emitter<FullArtistPlaylistState> emit) async {
    emit(LoadingState());
    try {
      final data = await _repository.searchPlaylist(event.inputText);
      emit(FullArtistPlaylistDataState(playlistData: data));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
