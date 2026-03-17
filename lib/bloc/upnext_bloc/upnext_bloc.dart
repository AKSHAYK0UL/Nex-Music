import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/model/songmodel.dart';

part 'upnext_event.dart';
part 'upnext_state.dart';

class UpnextBloc extends Bloc<UpnextEvent, UpnextState> {
  final SongstreamBloc _songstreamBloc;

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
  }

  Future<void> _loadUpcomingSongs(
    LoadUpcomingSongsEvent event,
    Emitter<UpnextState> emit,
  ) async {
    emit(UpnextLoadingState());

    try {
      final upcomingSongs = _getUpcomingSongs();
      final allPlaylistSongs = _songstreamBloc.getPlaylistSongs;
      final currentIndex = _getCurrentSongIndex();
      final shouldShowStartRadio = _shouldShowStartRadio(upcomingSongs);

      emit(UpnextLoadedState(
        upcomingSongs: upcomingSongs,
        allPlaylistSongs: allPlaylistSongs,
        currentSongIndex: currentIndex,
        shouldShowStartRadio: shouldShowStartRadio,
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
      emit((state as UpnextLoadedState).copyWith(isRadioLoading: true));
    } else {
      emit(UpnextLoadedState(
        upcomingSongs: [],
        shouldShowStartRadio: false,
        isRadioLoading: true,
      ));
    }

    try {
      _songstreamBloc.add(StartRadioEvent(videoId: event.videoId));

      await Future.delayed(const Duration(milliseconds: 500));
      add(RefreshUpnextEvent());
    } catch (e) {
      emit(UpnextErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _removeSongFromUpnext(
    RemoveSongFromUpnextEvent event,
    Emitter<UpnextState> emit,
  ) async {
    _songstreamBloc.add(RemoveFromPlaylistEvent(videoId: event.videoId));

    add(RefreshUpnextEvent());
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
      final shouldShowStartRadio = _shouldShowStartRadio(upcomingSongs);

      emit(UpnextLoadedState(
        upcomingSongs: upcomingSongs,
        allPlaylistSongs: allPlaylistSongs,
        currentSongIndex: currentIndex,
        shouldShowStartRadio: shouldShowStartRadio,
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
    final currentIndex = _songstreamBloc.getCurrentSongIndex;
    final currentSong = _songstreamBloc.getCurrentSongData;

    List<Songmodel> upcomingSongs = [];

    if (currentIndex >= 0 && currentIndex < playlistSongs.length - 1) {
      upcomingSongs = playlistSongs.sublist(currentIndex + 1);
    } else if (playlistSongs.isNotEmpty && currentSong != null) {
      final currentSongIndex = playlistSongs.indexWhere(
        (song) => song.vId == currentSong.vId,
      );
      if (currentSongIndex >= 0 &&
          currentSongIndex < playlistSongs.length - 1) {
        upcomingSongs = playlistSongs.sublist(currentSongIndex + 1);
      }
    }

    return upcomingSongs;
  }

  int _getCurrentSongIndex() {
    final playlistSongs = _songstreamBloc.getPlaylistSongs;
    final currentIndex = _songstreamBloc.getCurrentSongIndex;
    final currentSong = _songstreamBloc.getCurrentSongData;

    if (currentIndex >= 0 && currentIndex < playlistSongs.length) {
      return currentIndex;
    } else if (playlistSongs.isNotEmpty && currentSong != null) {
      return playlistSongs.indexWhere((song) => song.vId == currentSong.vId);
    }
    return -1;
  }

  bool _shouldShowStartRadio(List<Songmodel> upcomingSongs) {
    final playlistSongs = _songstreamBloc.getPlaylistSongs;
    final songstreamState = _songstreamBloc.state;
    final isLoading = songstreamState is LoadingState;

    return upcomingSongs.isEmpty && playlistSongs.length <= 1 && !isLoading;
  }

  bool get isSongstreamLoading => _songstreamBloc.state is LoadingState;

  Songmodel? get currentSongData => _songstreamBloc.getCurrentSongData;
}
