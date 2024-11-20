import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'full_artist_event.dart';
part 'full_artist_state.dart';

class FullArtistSongBloc
    extends Bloc<FullArtistSongEvent, FullArtistSongState> {
  final Repository _repository;
  FullArtistSongBloc(this._repository) : super(FullArtistInitial()) {
    on<GetArtistSongsEvent>(_getArtistId);
  }
  Future<void> _getArtistId(
      GetArtistSongsEvent event, Emitter<FullArtistSongState> emit) async {
    emit(LoadingStata());
    try {
      final artistSongs = await _repository.getArtistSongs(event.artistId);
      emit(ArtistSongsState(artistSongs: artistSongs));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
