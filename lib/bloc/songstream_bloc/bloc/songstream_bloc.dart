import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'songstream_event.dart';
part 'songstream_state.dart';

class SongstreamBloc extends Bloc<SongstreamEvent, SongstreamState> {
  final Repository repository;
  SongstreamBloc(this.repository) : super(SongstreamInitial()) {
    on<GetSongStreamUrlEvent>(_getSongUrl);
  }
  Future<void> _getSongUrl(
      GetSongStreamUrlEvent event, Emitter<SongstreamState> emit) async {
    emit(LoadingState());
    try {
      final songUrl = await repository.getSongUrl(event.songUrl);
      emit(StreamSongUrlState(songurl: songUrl));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
