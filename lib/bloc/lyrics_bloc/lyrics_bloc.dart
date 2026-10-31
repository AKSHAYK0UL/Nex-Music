import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/helper_function/lyrics_cache/lyrics_cache.dart';
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

    int? durationSec = event.durationSeconds;
    if (durationSec == null || durationSec <= 0) {
      durationSec = _parseDurationString(event.songData.duration);
    }

    try {
      LyricModel? lyrics;

      // For offline/downloaded songs, try loading from disk first.
      if (event.songData.isLocal) {
        lyrics = await loadLyricsFromFile(
          event.songData.songName,
          event.songData.vId,
        );
      }

      // Fall back to network if not found locally (or not a local song).
      lyrics ??= await _repository.getLyrics(
        title: event.songData.songName,
        artist: event.songData.artist.name,
        videoId: event.songData.vId,
        durationSeconds: durationSec,
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

  static int? _parseDurationString(String? durationStr) {
    if (durationStr == null || durationStr.trim().isEmpty) return null;
    final parts = durationStr.trim().split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final s = int.tryParse(parts[1]);
      if (m != null && s != null) return m * 60 + s;
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final s = int.tryParse(parts[2]);
      if (h != null && m != null && s != null) return h * 3600 + m * 60 + s;
    }
    return null;
  }
}
