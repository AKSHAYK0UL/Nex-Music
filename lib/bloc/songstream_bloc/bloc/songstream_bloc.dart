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

  SongstreamBloc(this.repository, this._audioPlayer)
      : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl);
    on<PlayPauseEvent>(_togglePlayPause);
    on<CloseMiniPlayerEvent>(_closeMiniPlayer);
    on<SongCompletedEvent>(_onSongCompleted);
    on<SeekToEvent>(_seekTo);
    on<PauseEvent>(_togglePause);
    on<PlayEvent>(_togglePlay);

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
      // Handle completed state
      if (state.processingState == ProcessingState.completed) {
        add(SongCompletedEvent());
      }
    });
  }

  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

  // Reset audio player (stop, clear state, ...)
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

  // Fetch the song URL and handle playback
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayer();
    emit(LoadingState());

    songData = event.songData;

    try {
      final songUrl = await repository.getSongUrl(event.songData.vId);
      _currentSongUrl = songUrl.toString();

      // Load the song and handle potential errors
      await _audioPlayer.setUrl(_currentSongUrl).then((_) {
        _audioPlayer.play();
        _isPlaying = true;

        emit(PlayingState(songData: songData!));
      }).catchError((error) {
        // If error occurs during audio load, emit an error state
        emit(ErrorState(errorMessage: "Error loading song: $error"));
      });
    } catch (e) {
      // Handle errors (network or otherwise) when fetching song URL
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//Pause Event
  void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
    emit(PausedState(songData: songData!));
  }

//Play Event
  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    emit(PlayingState(songData: songData!));
  }

  // Toggle between play and pause
  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
      emit(PausedState(songData: songData!));
    } else {
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: songData!));
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

  // Handle when the song is completed
  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.pause();
    _isPlaying = false;

    // Emit PausedState after song completion
    emit(PausedState(songData: songData!));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
