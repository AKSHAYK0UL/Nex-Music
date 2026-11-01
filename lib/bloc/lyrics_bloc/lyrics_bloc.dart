import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/enum/lyrics_source.dart';
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
    on<SwitchLyricsSourceEvent>(_onSwitchSource);
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
      // For offline/downloaded songs, try loading from disk first.
      if (event.songData.isLocal) {
        final cached = await loadLyricsFromFile(
          event.songData.songName,
          event.songData.vId,
        );
        if (cached != null && cached.hasLyrics) {
          emit(LyricsLoadedState(
            songData: event.songData,
            lyricModel: cached,
            isSyncEnabled: cached.hasSyncedLyrics,
            source: LyricsSource.ytMusic,
            ytLyrics: cached,
          ));
          return;
        }
      }

      // Fetch both sources in parallel
      final both = await _repository.fetchBothLyricsSources(
        title: event.songData.songName,
        artist: event.songData.artist.name,
        videoId: event.songData.vId,
        durationSeconds: durationSec,
      );

      final ytLyrics = both.ytLyrics;
      final lrclibLyrics = both.lrclibLyrics;

      // Pick best default: prefer YT ( perfect timing)
      final primary =
          (ytLyrics != null && ytLyrics.hasLyrics) ? ytLyrics : lrclibLyrics;
      final defaultSource = (ytLyrics != null && ytLyrics.hasLyrics)
          ? LyricsSource.ytMusic
          : LyricsSource.lrclib;

      if (primary != null && primary.hasLyrics) {
        emit(LyricsLoadedState(
          songData: event.songData,
          lyricModel: primary,
          isSyncEnabled: primary.hasSyncedLyrics,
          source: defaultSource,
          ytLyrics: ytLyrics,
          lrclibLyrics: lrclibLyrics,
        ));
      } else {
        emit(LyricsNotFoundState(songData: event.songData));
      }
    } catch (e) {
      emit(LyricsErrorState(
        errorMessage: e.toString(),
        songData: event.songData,
      ));
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

  Future<void> _onSwitchSource(
    SwitchLyricsSourceEvent event,
    Emitter<LyricsState> emit,
  ) async {
    if (state is! LyricsLoadedState) return;
    final current = state as LyricsLoadedState;
    if (current.source == event.source) return;

    // Check if we already have the target source cached in state
    final targetLyrics = event.source == LyricsSource.ytMusic
        ? current.ytLyrics
        : current.lrclibLyrics;

    if (targetLyrics != null && targetLyrics.hasLyrics) {
      // Instant switch already cached
      emit(current.copyWith(
        lyricModel: targetLyrics,
        source: event.source,
        isSyncEnabled: targetLyrics.hasSyncedLyrics,
      ));
    } else {
      // Need to fetch show loading briefly then restore
      emit(LyricsLoadingState(songData: current.songData));
      try {
        final durationSec = _parseDurationString(current.songData.duration);
        LyricModel? fetched;
        if (event.source == LyricsSource.ytMusic) {
          fetched = await _repository.getLyricsYtOnly(
            title: current.songData.songName,
            artist: current.songData.artist.name,
            videoId: current.songData.vId,
            durationSeconds: durationSec,
          );
        } else {
          fetched = await _repository.getLyricsLrclibOnly(
            title: current.songData.songName,
            artist: current.songData.artist.name,
            videoId: current.songData.vId,
            durationSeconds: durationSec,
          );
        }

        if (fetched != null && fetched.hasLyrics) {
          emit(current.copyWith(
            lyricModel: fetched,
            source: event.source,
            isSyncEnabled: fetched.hasSyncedLyrics,
            ytLyrics: event.source == LyricsSource.ytMusic
                ? fetched
                : current.ytLyrics,
            lrclibLyrics: event.source == LyricsSource.lrclib
                ? fetched
                : current.lrclibLyrics,
          ));
        } else {
          // Revert to previous state with error snack handled by UI
          emit(current.copyWith(
            ytLyrics: event.source == LyricsSource.ytMusic
                ? const LyricModel()
                : current.ytLyrics,
            lrclibLyrics: event.source == LyricsSource.lrclib
                ? const LyricModel()
                : current.lrclibLyrics,
          ));
        }
      } catch (_) {
        emit(current);
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
