import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'lyrics_event.dart';
part 'lyrics_state.dart';

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final Repository _repository;

  LyricsBloc({required Repository repository})
      : _repository = repository,
        super(LyricsInitialState()) {
    on<LoadLyricsEvent>(_onLoadLyrics);
    on<ToggleSyncLyricsEvent>(_onToggleSync);
  }

  Future<void> _onLoadLyrics(
    LoadLyricsEvent event,
    Emitter<LyricsState> emit,
  ) async {
    // If already loaded for the same song, don't re-emit loading
    if (state is LyricsLoadedState &&
        (state as LyricsLoadedState).songData.vId == event.songData.vId) {
      return;
    }

    emit(LyricsLoadingState(songData: event.songData));

    try {
      final lyrics = await _repository.getLyrics(
        title: event.songData.songName,
        artist: event.songData.artist.name,
        videoId: event.songData.vId,
        durationSeconds: event.durationSeconds,
      );

      if (lyrics != null && lyrics.hasLyrics) {
        emit(
          LyricsLoadedState(
            songData: event.songData,
            lyricModel: lyrics,
            isSyncEnabled: lyrics.hasSyncedLyrics,
          ),
        );
      } else {
        emit(LyricsNotFoundState(songData: event.songData));
      }
    } catch (e) {
      emit(
        LyricsErrorState(
          errorMessage: e.toString(),
          songData: event.songData,
        ),
      );
    }
  }

  void _onToggleSync(
    ToggleSyncLyricsEvent event,
    Emitter<LyricsState> emit,
  ) {
    if (state is LyricsLoadedState) {
      final current = state as LyricsLoadedState;
      if (current.lyricModel.hasSyncedLyrics) {
        emit(current.copyWith(isSyncEnabled: !current.isSyncEnabled));
      }
    }
  }
}
