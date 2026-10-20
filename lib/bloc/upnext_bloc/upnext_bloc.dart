import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/model/songmodel.dart';

part 'upnext_event.dart';
part 'upnext_state.dart';

class UpnextBloc extends Bloc<UpnextEvent, UpnextState> {
  final SongstreamBloc _songstreamBloc;
  StreamSubscription<SongstreamState>? _songstreamSubscription;

  UpnextBloc({
    required SongstreamBloc songstreamBloc,
  })  : _songstreamBloc = songstreamBloc,
        super(UpnextInitial()) {
    on<LoadUpcomingSongsEvent>(_loadUpcomingSongs);
    on<StartRadioFromUpnextEvent>(_startRadio);
    on<RemoveSongFromUpnextEvent>(_removeSongFromUpnext);
    on<PlaySongFromUpnextEvent>(_playSongFromUpnext);
    on<RefreshUpnextEvent>(_refreshUpnext);
    on<ClearUpnextEvent>(_clearUpnext);

    _songstreamSubscription = _songstreamBloc.stream.listen((_) {
      add(RefreshUpnextEvent());
    });
  }

  @override
  Future<void> close() {
    _songstreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadUpcomingSongs(
    LoadUpcomingSongsEvent event,
    Emitter<UpnextState> emit,
  ) async {
    if (state is! UpnextLoadedState) {
      emit(UpnextLoadingState());
    }

    try {
      final upcomingSongs = _getUpcomingSongs();
      final allPlaylistSongs = _songstreamBloc.getPlaylistSongs;
      final currentIndex = _getCurrentSongIndex();
      final isRadioLoading = _songstreamBloc.isRadioLoading;
      final shouldShowStartRadio =
          _shouldShowStartRadio(upcomingSongs, isRadioLoading);

      emit(UpnextLoadedState(
        upcomingSongs: upcomingSongs,
        allPlaylistSongs: allPlaylistSongs,
        currentSongIndex: currentIndex,
        shouldShowStartRadio: shouldShowStartRadio,
        isRadioLoading: isRadioLoading,
      ));
    } catch (e) {
      emit(UpnextErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _startRadio(
    StartRadioFromUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    if (state is UpnextLoadedState) {
      emit((state as UpnextLoadedState).copyWith(
        isRadioLoading: true,
        shouldShowStartRadio: false,
      ));
    } else {
      emit(UpnextLoadedState(
        upcomingSongs: [],
        shouldShowStartRadio: false,
        isRadioLoading: true,
      ));
    }

    try {
      _songstreamBloc.add(StartRadioEvent(videoId: event.videoId));
    } catch (e) {
      emit(UpnextErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _removeSongFromUpnext(
    RemoveSongFromUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    _songstreamBloc.add(RemoveFromPlaylistEvent(videoId: event.videoId));
  }

  Future<void> _playSongFromUpnext(
    PlaySongFromUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    _songstreamBloc.add(GetSongUrlOnShuffleEvent(songData: event.songData));
  }

  Future<void> _refreshUpnext(
    RefreshUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    try {
      final upcomingSongs = _getUpcomingSongs();
      final allPlaylistSongs = _songstreamBloc.getPlaylistSongs;
      final currentIndex = _getCurrentSongIndex();
      final isRadioLoading = _songstreamBloc.isRadioLoading;
      final shouldShowStartRadio =
          _shouldShowStartRadio(upcomingSongs, isRadioLoading);

      emit(UpnextLoadedState(
        upcomingSongs: upcomingSongs,
        allPlaylistSongs: allPlaylistSongs,
        currentSongIndex: currentIndex,
        shouldShowStartRadio: shouldShowStartRadio,
        isRadioLoading: isRadioLoading,
      ));
    } catch (e) {
      emit(UpnextErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _clearUpnext(
    ClearUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    emit(UpnextInitial());
  }

  List<Songmodel> _getUpcomingSongs() {
    final playlistSongs = _songstreamBloc.getPlaylistSongs;
    final currentIndex = _getCurrentSongIndex();

    if (currentIndex >= 0 && currentIndex < playlistSongs.length - 1) {
      return playlistSongs.sublist(currentIndex + 1);
    }
    return [];
  }

  int _getCurrentSongIndex() {
    final playlistSongs = _songstreamBloc.getPlaylistSongs;
    final currentSong = _songstreamBloc.getCurrentSongData;
    final currentIndex = _songstreamBloc.getCurrentSongIndex;

    if (currentSong != null && playlistSongs.isNotEmpty) {
      final foundIndex =
          playlistSongs.indexWhere((song) => song.vId == currentSong.vId);
      if (foundIndex != -1) {
        return foundIndex;
      }
    }

    if (currentIndex >= 0 && currentIndex < playlistSongs.length) {
      return currentIndex;
    }
    return -1;
  }

  bool _shouldShowStartRadio(List<Songmodel> upcomingSongs,
      [bool? isRadioLoading]) {
    final playlistSongs = _songstreamBloc.getPlaylistSongs;
    final songstreamState = _songstreamBloc.state;
    final isLoading = songstreamState is LoadingState ||
        (isRadioLoading ?? _songstreamBloc.isRadioLoading);

    return upcomingSongs.isEmpty && playlistSongs.length <= 1 && !isLoading;
  }

  bool get isSongstreamLoading => _songstreamBloc.state is LoadingState;

  Songmodel? get currentSongData => _songstreamBloc.getCurrentSongData;
}
