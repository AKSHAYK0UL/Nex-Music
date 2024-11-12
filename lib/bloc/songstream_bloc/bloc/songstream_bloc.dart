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
  final Repository _repository;
  final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Songmodel? _songData;
  Duration songDuration = Duration.zero;
  Stream<Duration>? songPosition;
  Stream<Duration>? bufferedPositionStream;
  bool _isLooping = false;
  List<Songmodel> _playlistSongs = [];
  int _currentSongIndex = -1; // Keep track of the current song in the playlist
  int _firstSongPlayedIndex =
      0; //store the index of first song played in the playlist
  bool _isMute = false;
  double _storedVolume = 0.0;

  SongstreamBloc(this._repository, this._audioPlayer)
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
    on<LoadingEvent>(_loading);
    on<CleanPlaylistEvent>(_cleanSongsPlaylist);
    on<MuteEvent>(_togglemute);

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

    _audioPlayer.playerStateStream.listen(
      (state) {
        if (state.processingState == ProcessingState.completed) {
          add(SongCompletedEvent());
        }
        if (state.playing &&
            state.processingState != ProcessingState.buffering) {
          add(PlayEvent());
        }

        if (state.processingState == ProcessingState.buffering) {
          add(LoadingEvent());
        }
      },
    );
  }

  // Fetch the song URL and handle playback
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayer();
    emit(LoadingState(songData: event.songData));

    _songData = event.songData;
    _firstSongPlayedIndex = event.songIndex;
    try {
      final songUrl = await _repository.getSongUrl(_songData!.vId);
      await _audioPlayer.setUrl(songUrl.toString());
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: _songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//when on shuffle
  Future<void> _getSongUrlOnShuffle(
      GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
    emit(LoadingState(songData: event.songData));
    _songData = event.songData;
    try {
      final songUrl = await _repository.getSongUrl(_songData!.vId);
      await _audioPlayer.setUrl(songUrl.toString());
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: _songData!));
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
    return _songData!;
  }

//first song Played index
  int get getFirstSongPlayedIndex {
    return _firstSongPlayedIndex;
  }

  //get mute status
  bool get getMuteStatus {
    return _isMute;
  }

  //Mute Audio Player
  void _togglemute(MuteEvent event, Emitter<SongstreamState> emit) {
    final volume = _audioPlayer.volume;
    _isMute = !_isMute;
    if (volume != 0.0) {
      _storedVolume = volume;
      _audioPlayer.setVolume(0.0);
    } else {
      _audioPlayer.setVolume(_storedVolume);
    }
    if (_isPlaying) {
      emit(PlayingState(songData: _songData!));
    } else {
      emit(PausedState(songData: _songData!));
    }
  }

  //add loading stata
  void _loading(LoadingEvent event, Emitter<SongstreamState> emit) {
    emit(LoadingState(songData: _songData!));
  }

  // Pause Event
  void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = false;
    _audioPlayer.pause();
    emit(PausedState(songData: _songData!));
  }

  // Play Event
  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = true;
    _audioPlayer.play();
    emit(PlayingState(songData: _songData!));
  }

  // Toggle between play and pause
  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
      emit(PausedState(songData: _songData!));
    } else {
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(songData: _songData!));
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
    songDuration = Duration.zero;

    _audioPlayer.seek(Duration.zero); // Reset position
  }

  // Handle when the song is completed
  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) async {
    if (_playlistSongs.isNotEmpty) {
      if (!_isLooping) {
        _currentSongIndex++;
        if (_currentSongIndex < _playlistSongs.length &&
            _currentSongIndex != _firstSongPlayedIndex) {
          add(GetSongUrlOnShuffleEvent(
              songData: _playlistSongs[_currentSongIndex]));
        }
        if (_currentSongIndex < _playlistSongs.length &&
            _currentSongIndex == _firstSongPlayedIndex) {
          if ((_currentSongIndex + 1) < _playlistSongs.length) {
            _currentSongIndex++;
            add(GetSongUrlOnShuffleEvent(
                songData: _playlistSongs[_currentSongIndex]));
          }
        }
        if (_currentSongIndex >= _playlistSongs.length) {
          _currentSongIndex = -1;
          _currentSongIndex++;
          add(GetSongUrlOnShuffleEvent(
              songData: _playlistSongs[_currentSongIndex]));
        }
      }
    } else {
      emit(PausedState(songData: _songData!));
    }
  }

  // Toggle loop state
  void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
    _isLooping = !_isLooping;
    final currentLoopMode = _audioPlayer.loopMode;

    if (currentLoopMode == LoopMode.off) {
      _audioPlayer.setLoopMode(LoopMode.one); // Set loop mode
    } else {
      _audioPlayer.setLoopMode(LoopMode.off); // Disable loop mode
    }
    if (_isPlaying) {
      emit(PlayingState(songData: _songData!));
    } else {
      emit(PausedState(songData: _songData!));
    }
  }

  // Handle playlist songs
  void _songsPlaylist(
      GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
    final list = event.songlist.toSet();
    _playlistSongs = list.toList();
  }

//clean the playlist
  void _cleanSongsPlaylist(
      CleanPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = [];
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
