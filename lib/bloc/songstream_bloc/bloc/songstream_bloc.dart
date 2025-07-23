// import 'dart:async';
// import 'dart:io';
// import 'package:audio_service/audio_service.dart';
// import 'package:bloc_concurrency/bloc_concurrency.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:nex_music/core/services/hive_singleton.dart';
// import 'package:nex_music/model/audioplayerstream.dart';
// import 'package:nex_music/model/songmodel.dart';
// import 'package:nex_music/repository/db_repository/db_repository.dart';
// import 'package:nex_music/repository/home_repo/repository.dart';
// import 'package:nex_music/utils/audioutils/audio_handler.dart';
// import 'package:nex_music/utils/audioutils/audioplayerstream.dart';

// part 'songstream_event.dart';
// part 'songstream_state.dart';

// class SongstreamBloc extends Bloc<SongstreamEvent, SongstreamState> {
//   final Repository _repository;
//   final AudioPlayer _audioPlayer;
//   final DbRepository _dbRepository;
//   final HiveDataBaseSingleton _dbInstance;
//   final AudioPlayerHandler _audioPlayerHandler;

//   bool _isPlaying = false;
//   Songmodel? _songData;
//   Duration songDuration = Duration.zero;
//   Stream<Duration>? songPosition;
//   Stream<Duration>? bufferedPositionStream;
//   List<Songmodel> _playlistSongs = [];
//   int _currentSongIndex = -1;
//   int _firstSongPlayedIndex = 0;
//   bool _isMute = false;
//   double _storedVolume = 0.0;
//   bool _songLoaded = false;
//   List<Songmodel> _storeQuicksPicksList = [];

//   SongstreamBloc(
//     this._repository,
//     this._audioPlayer,
//     this._audioPlayerHandler,
//     this._dbRepository,
//     this._dbInstance,
//   ) : super(SongstreamInitial()) {
//     on<GetSongStreamEvent>(_getSongUrl, transformer: restartable());
//     on<GetSongUrlOnShuffleEvent>(_getSongUrlOnShuffle,
//         transformer: restartable());
//     on<PlayPauseEvent>(_togglePlayPause);
//     on<PauseEvent>(_togglePause);
//     on<PlayEvent>(_togglePlay);
//     on<SeekToEvent>(_seekTo);
//     on<LoopEvent>(_toggleLoop);
//     on<MuteEvent>(_toggleMute);
//     on<PlayNextSongEvent>(_playNextSong);
//     on<PlayPreviousSongEvent>(_playPreviousSong);
//     on<AddToPlayNextEvent>(_addToPlayNext);
//     on<LoadingEvent>(_loading);
//     on<ResetPlaylistEvent>(_resetPlaylist);
//     on<CleanPlaylistEvent>(_cleanSongsPlaylist);
//     on<StoreQuickPicksSongsEvent>(_storeQuickPicks);
//     on<DisposeAudioPlayerEvent>(_disposeAudioPlayer);
//     on<CloseMiniPlayerEvent>(_closeMiniPlayer);
//     on<SongCompletedEvent>(_onSongCompleted);
//     on<UpdateUIEvent>(_updateUIFromBackground);
//     on<GetSongPlaylistEvent>(_songsPlaylist);

//     songPosition = _audioPlayer.positionStream;
//     bufferedPositionStream = _audioPlayer.bufferedPositionStream;

//     _initializeAudioPlayerListeners();
//   }

//   Stream<AudioPlayerStream> get getAudioPlayerStreamData =>
//       AudioPlayerStreamUtil.audioPlayerStreamData(
//         songPosition: songPosition,
//         bufferedPositionStream: bufferedPositionStream,
//       );

//   void _initializeAudioPlayerListeners() {
//     _audioPlayer.durationStream.listen((duration) {
//       songDuration = duration ?? Duration.zero;
//       if (duration != null) {
//         _audioPlayerHandler.updateMediaItemDuration(duration);
//       }
//     });

//     _audioPlayer.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         add(SongCompletedEvent());
//       }
//       if (state.processingState == ProcessingState.buffering ||
//           state.processingState == ProcessingState.loading) {
//         add(LoadingEvent());
//       }
//       if (_songLoaded &&
//           state.processingState != ProcessingState.buffering &&
//           state.processingState != ProcessingState.loading) {
//         if (state.playing && this.state is! PlayingState) {
//           add(PlayEvent());
//         } else if (!state.playing && this.state is! PausedState) {
//           add(PauseEvent());
//         }
//       }
//     });

//     _audioPlayer.positionStream.listen((position) {
//       if (Platform.isWindows &&
//           _audioPlayer.loopMode == LoopMode.one &&
//           position.inSeconds == songDuration.inSeconds - 1) {
//         _audioPlayer.seek(Duration.zero);
//         if (!_audioPlayer.playing) {
//           _audioPlayer.play();
//         }
//       }
//     });

//     if (Platform.isWindows) {
//       _audioPlayer.playbackEventStream.listen((event) {
//         if (!_isPlaying && _songLoaded) {
//           _audioPlayer.play();
//         }
//       });
//     }
//   }

//   Future<void> _getSongUrl(
//       GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
//     _resetAudioPlayer();
//     emit(LoadingState(songData: event.songData));
//     _songData = event.songData;
//     _firstSongPlayedIndex = event.songIndex;
//     _currentSongIndex++;
//     _playlistSongs.insert(_currentSongIndex, _songData!);

//     _audioPlayerHandler.setMediaItem(MediaItem(
//       id: _songData!.vId,
//       title: _songData!.songName,
//       artist: _songData!.artist.name,
//       artUri: _songData!.isLocal
//           ? Uri.file(_songData!.thumbnail)
//           : Uri.parse(_songData!.thumbnail),
//       duration: songDuration,
//     ));

//     try {
//       if (_songData!.isLocal && _songData!.localFilePath != null) {
//         await _audioPlayer.setFilePath(_songData!.localFilePath!);
//       } else {
//         final qualityInfo = await _dbInstance.getData;
//         final songRawInfo = await _repository.getSongUrl(
//             _songData!.vId, qualityInfo.audioQuality);
//         await _audioPlayer.setUrl(
//           songRawInfo.url.toString(),
//           initialPosition: const Duration(seconds: 0),
//           // headers: {"Range": "bytes=0-${songRawInfo.totalBytes}"},
//         );
//       }

//       if (Platform.isWindows) {
//         await _audioPlayer.load();
//         await Future.delayed(const Duration(milliseconds: 100));
//       }

//       _audioPlayer.play();
//       _isPlaying = true;
//       _songLoaded = true;
//       if (!_songData!.isLocal) {
//         _dbRepository.addToRecentPlayedCollection(_songData!);
//       }
//       emit(PlayingState(songData: _songData!));
//     } catch (e) {
//       emit(ErrorState(errorMessage: "Error fetching song: $e"));
//     }
//   }

//   Future<void> _getSongUrlOnShuffle(
//       GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
//     _resetAudioPlayerWhenOnShuffle();
//     emit(LoadingState(songData: event.songData));
//     _songData = event.songData;

//     _audioPlayerHandler.setMediaItem(MediaItem(
//       id: _songData!.vId,
//       title: _songData!.songName,
//       artist: _songData!.artist.name,
//       artUri: _songData!.isLocal
//           ? Uri.file(_songData!.thumbnail)
//           : Uri.parse(_songData!.thumbnail),
//       duration: songDuration,
//     ));

//     try {
//       if (_songData!.isLocal && _songData!.localFilePath != null) {
//         await _audioPlayer.setFilePath(_songData!.localFilePath!);
//       } else {
//         final qualityInfo = await _dbInstance.getData;
//         final songRawInfo = await _repository.getSongUrl(
//             _songData!.vId, qualityInfo.audioQuality);
//         await _audioPlayer.setUrl(
//           songRawInfo.url.toString(),
//           initialPosition: const Duration(seconds: 0),
//           // headers: {"Range": "bytes=0-${songRawInfo.totalBytes}"},
//         );
//       }

//       if (Platform.isWindows) {
//         await _audioPlayer.load();
//         await Future.delayed(const Duration(milliseconds: 100));
//       }

//       _audioPlayer.play();
//       _isPlaying = true;
//       _songLoaded = true;
//       if (!_songData!.isLocal) {
//         _dbRepository.addToRecentPlayedCollection(_songData!);
//       }
//       emit(PlayingState(songData: _songData!));
//     } catch (e) {
//       emit(ErrorState(errorMessage: "Error fetching song: $e"));
//     }
//   }

//   void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
//     _isPlaying ? add(PauseEvent()) : add(PlayEvent());
//   }

//   void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
//     _isPlaying = false;
//     _audioPlayer.pause();
//     emit(PausedState(songData: _songData!));
//   }

//   void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
//     _isPlaying = true;
//     _audioPlayer.play();
//     emit(PlayingState(songData: _songData!));
//   }

//   void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
//     _audioPlayer.seek(event.position);
//   }

//   void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
//     _audioPlayer.setLoopMode(
//         _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one);
//     emit(_isPlaying
//         ? PlayingState(songData: _songData!)
//         : PausedState(songData: _songData!));
//   }

//   void _toggleMute(MuteEvent event, Emitter<SongstreamState> emit) {
//     final volume = _audioPlayer.volume;
//     _isMute = !_isMute;
//     if (volume != 0.0) {
//       _storedVolume = volume;
//       _audioPlayer.setVolume(0.0);
//     } else {
//       _audioPlayer.setVolume(_storedVolume);
//     }
//     emit(_isPlaying
//         ? PlayingState(songData: _songData!)
//         : PausedState(songData: _songData!));
//   }

//   void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
//     _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;
//     add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
//   }

//   void _playPreviousSong(
//       PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
//     _currentSongIndex =
//         (_currentSongIndex - 1 + _playlistSongs.length) % _playlistSongs.length;
//     add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
//   }

//   void _onSongCompleted(
//       SongCompletedEvent event, Emitter<SongstreamState> emit) {
//     if (_audioPlayer.loopMode == LoopMode.one && Platform.isWindows) {
//       _audioPlayer.seek(Duration.zero);
//       _audioPlayer.play();
//     } else if (_playlistSongs.isNotEmpty) {
//       _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;
//       add(GetSongUrlOnShuffleEvent(
//           songData: _playlistSongs[_currentSongIndex]));
//     }
//   }

//   void _resetAudioPlayer() {
//     _songLoaded = false;
//     if (_isPlaying) _audioPlayer.pause();
//     _isPlaying = false;
//     songDuration = Duration.zero;
//     _audioPlayer.seek(Duration.zero);
//   }

//   void _resetAudioPlayerWhenOnShuffle() {
//     _songLoaded = false;
//     _isPlaying = false;
//     songDuration = Duration.zero;
//     _audioPlayer.seek(Duration.zero);
//   }

//   void _updateUIFromBackground(
//       UpdateUIEvent event, Emitter<SongstreamState> emit) {
//     if (state.runtimeType != CloseMiniPlayerState) {
//       _isPlaying ? add(PlayEvent()) : add(PauseEvent());
//     }
//   }

//   void _songsPlaylist(
//       GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _playlistSongs = event.songlist.toSet().toList();
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//   }

//   void _addToPlayNext(AddToPlayNextEvent event, Emitter<SongstreamState> emit) {
//     final insertIndex =
//         (_currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length)
//             ? _currentSongIndex + 1
//             : _playlistSongs.length;
//     _playlistSongs.insert(insertIndex, event.songData);
//     if (_currentSongIndex >= insertIndex) _currentSongIndex++;
//   }

//   void _loading(LoadingEvent event, Emitter<SongstreamState> emit) =>
//       emit(LoadingState(songData: _songData!));

//   void _resetPlaylist(ResetPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _playlistSongs = [];
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//   }

//   void _cleanSongsPlaylist(
//       CleanPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _playlistSongs = _storeQuicksPicksList;
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//   }

//   void _storeQuickPicks(
//           StoreQuickPicksSongsEvent event, Emitter<SongstreamState> emit) =>
//       _storeQuicksPicksList = event.quickPicks;

//   void _disposeAudioPlayer(
//           DisposeAudioPlayerEvent event, Emitter<SongstreamState> emit) =>
//       _audioPlayer.dispose();

//   Future<void> _closeMiniPlayer(
//       CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) async {
//     await _audioPlayer.pause();
//     _isPlaying = false;
//     emit(CloseMiniPlayerState());
//   }

//   @override
//   Future<void> close() {
//     _audioPlayer.dispose();
//     return super.close();
//   }

//   // Exposed getters
//   Songmodel? get getCurrentSongData => _songData;
//   int get getFirstSongPlayedIndex => _firstSongPlayedIndex;
//   bool get getLoopStatus => _audioPlayer.loopMode == LoopMode.one;
//   bool get getMuteStatus => _isMute;
// }

//=============================================================================

import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
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
  final HiveDataBaseSingleton _dbInstance;
  final AudioPlayerHandler _audioPlayerHandler;

  bool _isPlaying = false;
  Songmodel? _songData;
  Duration songDuration = Duration.zero;
  Stream<Duration>? songPosition;
  Stream<Duration>? bufferedPositionStream;
  List<Songmodel> _playlistSongs = [];
  int _currentSongIndex = -1;
  int _firstSongPlayedIndex = 0;
  bool _isMute = false;
  double _storedVolume = 0.0;
  bool _songLoaded = false;
  List<Songmodel> _storeQuicksPicksList = [];

  SongstreamBloc(
    this._repository,
    this._audioPlayer,
    this._audioPlayerHandler,
    this._dbRepository,
    this._dbInstance,
  ) : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl, transformer: restartable());
    on<GetSongUrlOnShuffleEvent>(_getSongUrlOnShuffle,
        transformer: restartable());
    on<PlayPauseEvent>(_togglePlayPause);
    on<PauseEvent>(_togglePause);
    on<PlayEvent>(_togglePlay);
    on<SeekToEvent>(_seekTo);
    on<LoopEvent>(_toggleLoop);
    on<MuteEvent>(_toggleMute);
    on<PlayNextSongEvent>(_playNextSong);
    on<PlayPreviousSongEvent>(_playPreviousSong);
    on<AddToPlayNextEvent>(_addToPlayNext);
    on<LoadingEvent>(_loading);
    on<ResetPlaylistEvent>(_resetPlaylist);
    on<CleanPlaylistEvent>(_cleanSongsPlaylist);
    on<StoreQuickPicksSongsEvent>(_storeQuickPicks);
    on<DisposeAudioPlayerEvent>(_disposeAudioPlayer);
    on<CloseMiniPlayerEvent>(_closeMiniPlayer);
    on<SongCompletedEvent>(_onSongCompleted);
    on<UpdateUIEvent>(_updateUIFromBackground);
    on<GetSongPlaylistEvent>(_songsPlaylist);
    on<SetSongDataToNullEvent>(_setSongDataToNull);
    songPosition = _audioPlayer.positionStream;
    bufferedPositionStream = _audioPlayer.bufferedPositionStream;

    _initializeAudioPlayerListeners();
    _initAudioSession();
  }

  Stream<AudioPlayerStream> get getAudioPlayerStreamData =>
      AudioPlayerStreamUtil.audioPlayerStreamData(
        songPosition: songPosition,
        bufferedPositionStream: bufferedPositionStream,
      );

  void _initializeAudioPlayerListeners() {
    _audioPlayer.durationStream.listen((duration) {
      songDuration = duration ?? Duration.zero;
      if (duration != null) {
        _audioPlayerHandler.updateMediaItemDuration(duration);
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        add(SongCompletedEvent());
      }
      if (state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading) {
        add(LoadingEvent());
      }
      if (_songLoaded &&
          state.processingState != ProcessingState.buffering &&
          state.processingState != ProcessingState.loading) {
        if (state.playing && this.state is! PlayingState) {
          add(PlayEvent());
        } else if (!state.playing && this.state is! PausedState) {
          add(PauseEvent());
        }
      }
    });
    //windows specific code
    // Windows-specific loop handling
    _audioPlayer.positionStream.listen((position) {
      if (Platform.isWindows &&
          _audioPlayer.loopMode == LoopMode.one &&
          position.inSeconds == songDuration.inSeconds - 1) {
        _audioPlayer.seek(Duration.zero);
        if (!_audioPlayer.playing) {
          _audioPlayer.play();
        }
      }
    });
    //auto play song
    if (Platform.isWindows) {
      _audioPlayer.playbackEventStream.listen((event) {
        if (!_isPlaying && _songLoaded) {
          _audioPlayer.play();
        }
      });
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.becomingNoisyEventStream.listen((ext) {
      // Headphones disconnected, pause audio
      if (_isPlaying) {
        add(PauseEvent());
      }
    });
    session.interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.pause) {
        if (_isPlaying) {
          add(PauseEvent());
        }
      } else if (event.type == AudioInterruptionType.duck) {
        //TODO
        // Lower the volume
      } else if (event.type == AudioInterruptionType.unknown) {
        //TODO
        // Unknown interruption
      }
    });
  }

// Grab the song URL, update the "Recently Played" list and start playing.
// (I know the function name isn’t ideal
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    print("SONG ID ${event.songData.vId}@@@");
    if (_songData != null &&
        event.songData.vId == _songData!.vId &&
        event.songData.isLocal == _songData!.isLocal) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
      return;
    }

    _resetAudioPlayer();

    _songData = event.songData;
    emit(LoadingState(songData: _songData!));
    _firstSongPlayedIndex = event.songIndex;
    _currentSongIndex++;
    _playlistSongs.insert(_currentSongIndex, _songData!);

    _audioPlayerHandler.setMediaItem(MediaItem(
      id: _songData!.vId,
      title: _songData!.songName,
      artist: _songData!.artist.name,
      artUri: _songData!.isLocal
          ? Uri.file(_songData!.thumbnail)
          : Uri.parse(_songData!.thumbnail),
      duration: songDuration,
    ));

    try {
      if (_songData!.isLocal && _songData!.localFilePath != null) {
        //test
        // _audioPlayer.pause();
        // add(PauseEvent());
        // _isPlaying = false;
        //test
        await _audioPlayer.setFilePath(_songData!.localFilePath!);
      } else {
        final qualityInfo = await _dbInstance.getData;
        final songRawInfo = await _repository.getSongUrl(
            _songData!.vId, qualityInfo.audioQuality);
        //experimental
        final audioSource = LockCachingAudioSource(songRawInfo.url);
        await _audioPlayer.setAudioSource(audioSource);
        // await _audioPlayer.setUrl(
        //   songRawInfo.url.toString(),
        //   initialPosition: const Duration(seconds: 0),
        //   // headers: {"Range": "bytes=0-${songRawInfo.totalBytes}"},
        // );
      }

      if (Platform.isWindows) {
        await _audioPlayer.load();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
      if (!_songData!.isLocal) {
        _dbRepository.addToRecentPlayedCollection(_songData!);
      }
      emit(PlayingState(songData: _songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song: $e"));
    }
  }

// Do exactly what [_getSongUrl] does, but with extra spice shuffle mode activated.
  Future<void> _getSongUrlOnShuffle(
      GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayerWhenOnShuffle();
    _songData = event.songData;
    emit(LoadingState(songData: _songData!));

    _audioPlayerHandler.setMediaItem(MediaItem(
      id: _songData!.vId,
      title: _songData!.songName,
      artist: _songData!.artist.name,
      artUri: _songData!.isLocal
          ? Uri.file(_songData!.thumbnail)
          : Uri.parse(_songData!.thumbnail),
      duration: songDuration,
    ));

    try {
      if (_songData!.isLocal && _songData!.localFilePath != null) {
        await _audioPlayer.setFilePath(_songData!.localFilePath!);
      } else {
        final qualityInfo = await _dbInstance.getData;
        final songRawInfo = await _repository.getSongUrl(
            _songData!.vId, qualityInfo.audioQuality);

        final audioSource = LockCachingAudioSource(songRawInfo.url);
        await _audioPlayer.setAudioSource(audioSource);
        // await _audioPlayer.setUrl(
        //   songRawInfo.url.toString(),
        //   initialPosition: const Duration(seconds: 0),
        //   // headers: {"Range": "bytes=0-${songRawInfo.totalBytes}"},
        // );
      }

      if (Platform.isWindows) {
        await _audioPlayer.load();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
      if (!_songData!.isLocal) {
        _dbRepository.addToRecentPlayedCollection(_songData!);
      }
      emit(PlayingState(songData: _songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song: $e"));
    }
  }

//emit pause/play state
  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
    _isPlaying ? add(PauseEvent()) : add(PlayEvent());
  }

  void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = false;
    _audioPlayer.pause();
    emit(PausedState(songData: _songData!));
  }

  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = true;
    _audioPlayer.play();
    emit(PlayingState(songData: _songData!));
  }

  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

  void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.setLoopMode(
        _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one);
    emit(_isPlaying
        ? PlayingState(songData: _songData!)
        : PausedState(songData: _songData!));
  }

  //Mute Audio Player
  void _toggleMute(MuteEvent event, Emitter<SongstreamState> emit) {
    final volume = _audioPlayer.volume;
    _isMute = !_isMute;
    if (volume != 0.0) {
      _storedVolume = volume;
      _audioPlayer.setVolume(0.0);
    } else {
      _audioPlayer.setVolume(_storedVolume);
    }
    emit(_isPlaying
        ? PlayingState(songData: _songData!)
        : PausedState(songData: _songData!));
  }

  void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
    _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;
    add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
    // //test
    // _currentSongIndex = (_currentSongIndex + 1) < _playlistSongs.length
    //     ? _currentSongIndex + 1
    //     : 0;
    // add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
    // //test
  }

  void _playPreviousSong(
      PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
    _currentSongIndex =
        (_currentSongIndex - 1 + _playlistSongs.length) % _playlistSongs.length;
    add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
  }

  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
    if (_audioPlayer.loopMode == LoopMode.one && Platform.isWindows) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_playlistSongs.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;
      add(GetSongUrlOnShuffleEvent(
          songData: _playlistSongs[_currentSongIndex]));
    }
  }

  void _resetAudioPlayer() {
    _songLoaded = false;
    if (_isPlaying) _audioPlayer.pause();
    _isPlaying = false;
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero);
  }

  void _resetAudioPlayerWhenOnShuffle() {
    _songLoaded = false;
    _isPlaying = false;
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero);
  }

//set current songdata object to null
  void _setSongDataToNull(
      SetSongDataToNullEvent event, Emitter<SongstreamState> emit) {
    _songData = null; //set to null
  }

// Refresh the UI when the app returns from the dead [background or recent apps].
  void _updateUIFromBackground(
      UpdateUIEvent event, Emitter<SongstreamState> emit) {
    if (state.runtimeType != CloseMiniPlayerState) {
      _isPlaying ? add(PlayEvent()) : add(PauseEvent());
    }
  }

  void _songsPlaylist(
      GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = event.songlist.toSet().toList();
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

  void _addToPlayNext(AddToPlayNextEvent event, Emitter<SongstreamState> emit) {
    // final insertIndex =
    //     (_currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length)
    //         ? _currentSongIndex + 1
    //         : _playlistSongs.length;
    // _playlistSongs.insert(insertIndex, event.songData);
    // if (_currentSongIndex >= insertIndex) _currentSongIndex++;
    final insertIndex =
        (_currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length)
            ? _currentSongIndex + 1
            : _playlistSongs.length;

    _playlistSongs.insert(insertIndex, event.songData);
    if (_currentSongIndex >= insertIndex) _currentSongIndex++;
  }

//emit loading state with currentsong data
  void _loading(LoadingEvent event, Emitter<SongstreamState> emit) =>
      emit(LoadingState(songData: _songData!));

  void _resetPlaylist(ResetPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = [];
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

  void _cleanSongsPlaylist(
      CleanPlaylistEvent event, Emitter<SongstreamState> emit) {
    _playlistSongs = _storeQuicksPicksList;
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
  }

  void _storeQuickPicks(
          StoreQuickPicksSongsEvent event, Emitter<SongstreamState> emit) =>
      _storeQuicksPicksList = event.quickPicks;

  void _disposeAudioPlayer(
          DisposeAudioPlayerEvent event, Emitter<SongstreamState> emit) =>
      _audioPlayer.dispose();

  Future<void> _closeMiniPlayer(
      CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) async {
    await _audioPlayer.pause();
    _isPlaying = false;
    emit(CloseMiniPlayerState());
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

  // Exposed getters
  Songmodel? get getCurrentSongData => _songData;
  int get getFirstSongPlayedIndex => _firstSongPlayedIndex;
  bool get getLoopStatus => _audioPlayer.loopMode == LoopMode.one;
  bool get getMuteStatus => _isMute;
}
