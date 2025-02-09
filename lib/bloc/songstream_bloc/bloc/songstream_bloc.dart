import 'dart:async';
import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/model/audioplayerstream.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:nex_music/utils/audioutils/audio_handler.dart';
import 'package:nex_music/utils/audioutils/audioplayerstream.dart';

part 'songstream_event.dart';
part 'songstream_state.dart';

class SongstreamBloc extends Bloc<SongstreamEvent, SongstreamState> {
  final Repository _repository;
  final AudioPlayer _audioPlayer;
  final DbRepository _dbRepository;
  bool _isPlaying = false; //default false
  Songmodel? _songData;
  Duration songDuration = Duration.zero;
  Stream<Duration>? songPosition;
  Stream<Duration>? bufferedPositionStream;
  bool _isLooping = false; //default false
  List<Songmodel> _playlistSongs = [];
  int _currentSongIndex = -1; // Keep track of the current song in the playlist
  int _firstSongPlayedIndex =
      0; //store the index of first song played in the playlist
  bool _isMute = false; //default false
  double _storedVolume = 0.0;
  double _resetVolume = 0.0;
  bool _songLoaded = false; //default false
  // late CancelableOperation<void> _currentOperation;

  List<Songmodel> _storeQuicksPicksList = [];
  final AudioPlayerHandler _audioPlayerHandler;

  SongstreamBloc(
    this._repository,
    this._audioPlayer,
    this._audioPlayerHandler,
    this._dbRepository,
  ) : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl,
        transformer: restartable<GetSongStreamEvent>());
    on<PlayPauseEvent>(_togglePlayPause);
    on<CloseMiniPlayerEvent>(_closeMiniPlayer);
    on<SongCompletedEvent>(_onSongCompleted);
    on<SeekToEvent>(_seekTo);
    on<PauseEvent>(_togglePause);
    on<PlayEvent>(_togglePlay);
    on<LoopEvent>(_toggleLoop);
    on<GetSongPlaylistEvent>(_songsPlaylist);
    on<GetSongUrlOnShuffleEvent>(_getSongUrlOnShuffle,
        transformer: restartable<GetSongUrlOnShuffleEvent>());
    on<LoadingEvent>(_loading);
    on<ResetPlaylistEvent>(_resetPlaylist);
    on<CleanPlaylistEvent>(_cleanSongsPlaylist);
    on<MuteEvent>(_togglemute);
    on<UpdataUIEvent>(_updateUIFromBackground);
    on<PlayNextSongEvent>(_playNextSong);
    on<PlayPreviousSongEvent>(_playPreviousSong);
    on<AddToPlayNextEvent>(_addToPlayNext);
    on<DisposeAudioPlayerEvent>(_disposeAudioPlayer);
    on<StoreQuickPicksSongsEvent>(_storeQuickPicks);

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
      (streamState) {
        if (streamState.processingState == ProcessingState.completed) {
          add(SongCompletedEvent());
        }

        if (streamState.processingState == ProcessingState.buffering ||
            streamState.processingState == ProcessingState.loading) {
          add(LoadingEvent());
        }
        if (_songLoaded &&
            (streamState.processingState != ProcessingState.buffering ||
                streamState.processingState != ProcessingState.loading)) {
          if (streamState.playing) {
            if (state.runtimeType != CloseMiniPlayerState) {
              add(PlayEvent());
            }
          } else if (!streamState.playing) {
            if (state.runtimeType != CloseMiniPlayerState) {
              add(PauseEvent());
            }
          }
        }
      },
    );
  }

  //Update UI when returning back from the Background / recent apps
  void _updateUIFromBackground(
      UpdataUIEvent event, Emitter<SongstreamState> emit) {
    if (state.runtimeType != CloseMiniPlayerState) {
      if (_isPlaying) {
        add(PlayEvent());
      } else {
        add(PauseEvent());
      }
    }
  }

  // Fetch the song URL and handle playback
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    //        await _currentOperation.cancel();

    // _currentOperation = CancelableOperation.fromFuture(

    //   onCancel: () {_resetAudioPlayer(),}, // Cleanup on cancellation
    // );

    _resetAudioPlayer();
    emit(LoadingState(songData: event.songData));
    _songData = event.songData;
    _firstSongPlayedIndex = event.songIndex;
    _currentSongIndex = _firstSongPlayedIndex;
    _audioPlayerHandler.setMediaItem(MediaItem(
      id: _songData!.vId,
      title: _songData!.songName,
      artist: _songData!.artist.name,
      artUri: Uri.parse(_songData!.thumbnail),
    ));
    try {
      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      final songUrl = await _repository.getSongUrl(_songData!.vId);
      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      await _audioPlayer.setUrl(songUrl.toString());
      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;

      //add to db recent played collection
      _dbRepository.addToRecentPlayedCollection(_songData!);

      // if (state is CloseMiniPlayerState) {
      //   _resetAudioPlayer();
      // } else {
      emit(PlayingState(songData: _songData!));
      // }
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//when on shuffle
  Future<void> _getSongUrlOnShuffle(
      GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayerWhenOnShuffle();
    emit(LoadingState(songData: event.songData));
    _songData = event.songData;
    _audioPlayerHandler.setMediaItem(MediaItem(
      id: _songData!.vId,
      title: _songData!.songName,
      artist: _songData!.artist.name,
      artUri: Uri.parse(_songData!.thumbnail),
    ));
    try {
      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      final songUrl = await _repository.getSongUrl(_songData!.vId);
      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      await _audioPlayer.setUrl(songUrl.toString());
      //  _audioPlayerHandler.setMediaItem(MediaItem(
      //     id: _songData!.vId,
      //     title: _songData!.songName,
      //     artist: _songData!.artist.name,
      //     artUri: Uri.parse(_songData!.thumbnail),
      //   ));

      // if (state is CloseMiniPlayerState) {
      //   return;
      // }
      _audioPlayer.setVolume(_resetVolume);
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
//add to db recent played collection
      _dbRepository.addToRecentPlayedCollection(_songData!);
      // if (state is CloseMiniPlayerState) {
      //   _resetAudioPlayer();
      // }
      // else {
      emit(PlayingState(songData: _songData!));
      // }
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//add to play next
  void _addToPlayNext(AddToPlayNextEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs.insert(_currentSongIndex + 1, event.songData);
  }

//seek forward/backward
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
      add(PauseEvent());
    } else {
      add(PlayEvent());
    }
  }

  //Play next
  // void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
  //   if ((_currentSongIndex + 1) < _playlistSongs.length) {
  //     _currentSongIndex++;
  //     add(GetSongStreamEvent(
  //         songData: _playlistSongs[_currentSongIndex],
  //         songIndex: _currentSongIndex));
  //   } else {
  //     _currentSongIndex = 0;
  //     add(GetSongStreamEvent(
  //         songData: _playlistSongs[_currentSongIndex],
  //         songIndex: _currentSongIndex));
  //   }
  // }

  // //play previous
  // void _playPreviousSong(
  //     PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
  //   if ((_currentSongIndex - 1) > 0) {
  //     _currentSongIndex--;
  //     add(GetSongStreamEvent(
  //         songData: _playlistSongs[_currentSongIndex],
  //         songIndex: _currentSongIndex));
  //   } else {
  //     _currentSongIndex = _playlistSongs.length - 1;
  //     add(
  //       GetSongStreamEvent(
  //         songData: _playlistSongs[_currentSongIndex],
  //         songIndex: _currentSongIndex,
  //       ),
  //     );
  //   }
  // }

  void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
    if ((_currentSongIndex + 1) < _playlistSongs.length) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }
    add(GetSongUrlOnShuffleEvent(
      songData: _playlistSongs[_currentSongIndex],
    ));
  }

  void _playPreviousSong(
      PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
    if ((_currentSongIndex - 1) >= 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex = _playlistSongs.length - 1;
    }
    add(GetSongUrlOnShuffleEvent(
      songData: _playlistSongs[_currentSongIndex],
    ));
  }

  // Close the mini player
  void _closeMiniPlayer(
      CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) {
    _audioPlayerHandler.onNotificationDeleted();
    _audioPlayer.pause();
    _isPlaying = false;
    emit(CloseMiniPlayerState());
  }

//reset audio player
  void _resetAudioPlayer() {
    _songLoaded = false;
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    songDuration = Duration.zero;

    _audioPlayer.seek(Duration.zero); // Reset position
  }

//reset audio player on shuffle
  void _resetAudioPlayerWhenOnShuffle() {
    _songLoaded = false;
    // Setting volume to 0 instead of using pause() because when using pause(), the notification disappears for a second.
    _resetVolume = _audioPlayer.volume;
    _audioPlayer.setVolume(0);
    _isPlaying = false;
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero); // Reset position
  }

  // Handle when the song is completed
  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
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
          _currentSongIndex = 0;
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
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
    final list = event.songlist.toSet();
    _playlistSongs = list.toList();
  }

  //Reset Playlist
  void _resetPlaylist(ResetPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = [];
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

//clean the playlist
  void _cleanSongsPlaylist(
      CleanPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = [];
    _playlistSongs = _storeQuicksPicksList;
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

  //store Quicks Picks
  void _storeQuickPicks(
      StoreQuickPicksSongsEvent event, Emitter<SongstreamState> emit) {
    _storeQuicksPicksList = event.quickPicks;
  }

  void _disposeAudioPlayer(
      DisposeAudioPlayerEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.dispose();
  }

//close
  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
