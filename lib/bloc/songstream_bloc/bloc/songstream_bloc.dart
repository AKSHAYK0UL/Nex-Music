import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/model/audioplayerstream.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:nex_music/utils/audioutils/audioplayerstream.dart';

part 'songstream_event.dart';
part 'songstream_state.dart';

class SongstreamBloc extends Bloc<SongstreamEvent, SongstreamState> {
  final Repository repository;
  final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Songmodel? songData;
  String _currentSongUrl = '';
  Duration songDuration = Duration.zero;
  Stream<Duration>? songPosition;
  Stream<Duration>? bufferedPositionStream;
  bool _isLooping = false;
  List<Songmodel> playlistSongs = [];
  int currentSongIndex = 1; // Keep track of the current song in the playlist

  SongstreamBloc(this.repository, this._audioPlayer)
      : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl);
    on<PlayPauseEvent>(_togglePlayPause);
    on<CloseMiniPlayerEvent>(_closeMiniPlayer);
    on<SongCompletedEvent>(_onSongCompleted);
    on<SeekToEvent>(_seekTo);
    on<PauseEvent>(_togglePause);
    on<PlayEvent>(_togglePlay);
    on<LoopEvent>(_toggleLoop);
    on<GetSongPlaylistEvent>(_songsPlaylist);
    on<GetSongUrlOnShuffleEvent>(_getSongUrlOnShuffle);

    songPosition = _audioPlayer.positionStream;
    bufferedPositionStream = _audioPlayer.bufferedPositionStream;

    _initializeAudioPlayerListeners();
  }

  // Combine the audio player streams into one
  Stream<AudioPlayerStream> get getAudioPlayerStreamData {
    return AudioPlayerStreamUtil.audioPlayerStreamData(
        songPosition: songPosition,
        bufferedPositionStream: bufferedPositionStream);
  }

  void _initializeAudioPlayerListeners() {
    _audioPlayer.durationStream.listen((duration) {
      songDuration = duration ?? Duration.zero; // Handle null duration
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        add(SongCompletedEvent());
      }
    });
  }

  // Fetch the song URL and handle playback
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayer();
    emit(LoadingState(songData: event.songData));

    songData = event.songData;
    try {
      final songUrl = await repository.getSongUrl(songData!.vId);
      _currentSongUrl = songUrl.toString();
      await _audioPlayer.setUrl(_currentSongUrl);
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//when on shuffle
  Future<void> _getSongUrlOnShuffle(
      GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
    emit(LoadingState(songData: event.songData));
    songData = event.songData;
    try {
      final songUrl = await repository.getSongUrl(songData!.vId);
      _currentSongUrl = songUrl.toString();
      await _audioPlayer.setUrl(_currentSongUrl);
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

  //Get loop status
  bool get getLoopStatus {
    return _isLooping;
  }

  // get current song Data
  Songmodel get getCurrentSongData {
    return songData!;
  }

  // Pause Event
  void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
    emit(PausedState(songData: songData!));
  }

  // Play Event
  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    emit(PlayingState(songData: songData!));
  }

  // Toggle between play and pause
  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
      emit(PausedState(songData: songData!, isLoop: _isLooping));
    } else {
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: songData!, isLoop: _isLooping));
    }
  }

  // Close the mini player
  void _closeMiniPlayer(
      CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    emit(CloseMiniPlayerState());
  }

  void _resetAudioPlayer() {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    songData = null;
    _currentSongUrl = '';
    songDuration = Duration.zero;

    _audioPlayer.seek(Duration.zero); // Reset position
  }

  // Handle when the song is completed
  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) async {
    // add(GetSongStreamEvent(songData: playlistSongs[currentSongIndex]));
    if (!_isLooping) {
      add(GetSongUrlOnShuffleEvent(songData: playlistSongs[currentSongIndex]));

      currentSongIndex++;
    }
  }

  // Toggle loop state
  void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
    _isLooping = !_isLooping;

    final currentLoopMode = _audioPlayer.loopMode;
    if (state is PlayingState) {
      final playingState = state as PlayingState;
      if (currentLoopMode == LoopMode.off) {
        _audioPlayer.setLoopMode(LoopMode.one); // Set loop mode
        emit(playingState.copyWith(isLoop: _isLooping));
      } else {
        _audioPlayer.setLoopMode(LoopMode.off); // Disable loop mode
        emit(playingState.copyWith(isLoop: _isLooping));
      }
    } else if (state is PausedState) {
      final pausedState = state as PausedState;
      if (currentLoopMode == LoopMode.off) {
        _audioPlayer.setLoopMode(LoopMode.one);
        emit(pausedState.copyWith(isLoop: _isLooping));
      } else {
        _audioPlayer.setLoopMode(LoopMode.off);
        emit(pausedState.copyWith(isLoop: _isLooping));
      }
    }
  }

  // Handle playlist songs
  void _songsPlaylist(
      GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
    playlistSongs = [];
    playlistSongs = event.songlist;
    print("PLAYLIST LENGTH ${playlistSongs.length}");
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
