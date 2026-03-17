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
  double _storedVolume = 0.5; // Default volume at 50%
  double _currentVolume = 0.5; // Current volume level
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
    on<SetVolumeEvent>(_setVolume);
    on<StartRadioEvent>(_startRadio);
    on<PlayIndividualSongEvent>(_playIndividualSong);
    on<RemoveFromPlaylistEvent>(_removeFromPlaylist);
    on<GetUpcomingSongsEvent>(_getUpcomingSongs);
    on<ShouldShowStartRadioEvent>(_shouldShowStartRadio);
    on<GetUpcomingSongsStateEvent>(_getUpcomingSongsState);
    on<PlaySongFromPlaylistEvent>(_playSongFromPlaylist,
        transformer: restartable());
    songPosition = _audioPlayer.positionStream;
    bufferedPositionStream = _audioPlayer.bufferedPositionStream;

    _initializeAudioPlayerListeners();
    _initAudioSession();

    // Set initial volume
    _audioPlayer.setVolume(_currentVolume);
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
    emit(LoadingState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));
    _firstSongPlayedIndex = event.songIndex;

    // Clear playlist and start fresh when playing a new song
    _playlistSongs.clear();
    _currentSongIndex = 0;
    _playlistSongs.add(_songData!);
    _storeQuicksPicksList.clear();

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
      emit(PlayingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));

      // After song starts playing, call auto radio to populate playlist
      _generateRadioSongs(_songData!.vId);
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song: $e"));
    }
  }

// Do exactly what [_getSongUrl] does, but with extra spice shuffle mode activated.
  Future<void> _getSongUrlOnShuffle(
      GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayerWhenOnShuffle();
    _songData = event.songData;

    // Update current song index to match the song being played
    _currentSongIndex =
        _playlistSongs.indexWhere((song) => song.vId == _songData!.vId);
    if (_currentSongIndex == -1) {
      // Song not found in playlist, add it and set index
      _playlistSongs.add(_songData!);
      _currentSongIndex = _playlistSongs.length - 1;
    }

    emit(LoadingState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));

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
        final qualityInfo = _dbInstance.getData;
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
      emit(PlayingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));
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
    emit(PausedState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));
  }

  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = true;
    _audioPlayer.play();
    emit(PlayingState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));
  }

  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

  void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.setLoopMode(
        _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one);
    emit(_isPlaying
        ? PlayingState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          )
        : PausedState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          ));
  }

  //Mute Audio Player
  void _toggleMute(MuteEvent event, Emitter<SongstreamState> emit) {
    _isMute = !_isMute;
    if (_isMute) {
      _storedVolume = _currentVolume;
      _audioPlayer.setVolume(0.0);
    } else {
      _currentVolume = _storedVolume;
      _audioPlayer.setVolume(_currentVolume);
    }
    emit(_isPlaying
        ? PlayingState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          )
        : PausedState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          ));
  }

  // Set Volume
  void _setVolume(SetVolumeEvent event, Emitter<SongstreamState> emit) {
    _currentVolume = event.volume.clamp(0.0, 1.0);
    if (!_isMute) {
      _audioPlayer.setVolume(_currentVolume);
    }
    // If volume==0== muted
    if (_currentVolume == 0.0) {
      _isMute = true;
    } else if (_isMute && _currentVolume > 0.0) {
      _isMute = false;
    }
    emit(_isPlaying
        ? PlayingState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          )
        : PausedState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          ));
  }

  // Start Radio Clear playlist and add radio songs
  Future<void> _startRadio(
      StartRadioEvent event, Emitter<SongstreamState> emit) async {
    try {
      final radioSongs = await _repository.getRadioSongs(event.videoId);
      if (radioSongs.isNotEmpty) {
        // Clear playlist and add radio songs
        _playlistSongs.clear();
        _playlistSongs.addAll(radioSongs);
        _currentSongIndex = 0;

        if (_songData == null) {
          add(GetSongStreamEvent(songData: radioSongs[0], songIndex: 0));
        }
      }
    } catch (e) {
      print("Error starting radio: $e");
    }
  }

  // Play individual song with complete state reset
  Future<void> _playIndividualSong(
      PlayIndividualSongEvent event, Emitter<SongstreamState> emit) async {
    // Complete reset of all state
    _resetAudioPlayer();
    _playlistSongs.clear();
    _storeQuicksPicksList.clear();
    _currentSongIndex = 0;
    _firstSongPlayedIndex = event.songIndex;

    // Set the song data
    _songData = event.songData;
    _playlistSongs.add(_songData!);

    emit(LoadingState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));

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
        final qualityInfo = _dbInstance.getData;
        final songRawInfo = await _repository.getSongUrl(
            _songData!.vId, qualityInfo.audioQuality);
        final audioSource = LockCachingAudioSource(songRawInfo.url);
        await _audioPlayer.setAudioSource(audioSource);
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
      emit(PlayingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));

      // After song starts playing, call auto radio to populate playlist
      _generateRadioSongs(event.songData.vId);
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song: $e"));
    }
  }

  void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
    if (_playlistSongs.isEmpty) return;

    // Move to next song in playlist
    _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;

    // Check if we need to load more radio songs (when near end of playlist)
    if (_currentSongIndex >= _playlistSongs.length - 3 && _songData != null) {
      _loadMoreRadioSongs(_songData!.vId);
    }

    add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
  }

  // Helper method to load more radio songs in the background
  Future<void> _loadMoreRadioSongs(String videoId) async {
    try {
      final moreRadioSongs = await _repository.getRadioSongs(videoId);
      if (moreRadioSongs.isNotEmpty) {
        // Add new radio songs to playlist, avoiding duplicates
        for (final song in moreRadioSongs) {
          if (!_playlistSongs.any((s) => s.vId == song.vId)) {
            _playlistSongs.add(song);
          }
        }
      }
    } catch (e) {
      print("Error loading more radio songs: $e");
    }
  }

  // Helper method to generate radio songs for a given video ID
  Future<void> _generateRadioSongs(String videoId) async {
    try {
      final radioSongs = await _repository.getRadioSongs(videoId);
      if (radioSongs.isNotEmpty) {
        // Add radio songs to playlist after the current song
        for (final song in radioSongs) {
          if (!_playlistSongs.any((s) => s.vId == song.vId)) {
            _playlistSongs.add(song);
          }
        }
      }
    } catch (e) {
      print("Error generating radio songs: $e");
    }
  }

  void _playPreviousSong(
      PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
    // Get current position of the song
    final currentPosition = _audioPlayer.position;

    // If song has been playing for more than 5 seconds, restart current song
    if (currentPosition.inSeconds > 5) {
      _audioPlayer.seek(Duration.zero);
      if (!_audioPlayer.playing) {
        _audioPlayer.play();
      }
    } else {
      // If current song is the first song in the playlist, just reset it
      if (_playlistSongs.isEmpty || _currentSongIndex == 0) {
        _audioPlayer.seek(Duration.zero);
        if (!_audioPlayer.playing) {
          _audioPlayer.play();
        }
        return;
      }

      // Play previous song in playlist
      _currentSongIndex = (_currentSongIndex - 1 + _playlistSongs.length) %
          _playlistSongs.length;
      add(GetSongUrlOnShuffleEvent(
          songData: _playlistSongs[_currentSongIndex]));
    }
  }

  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
    if (_audioPlayer.loopMode == LoopMode.one && Platform.isWindows) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_playlistSongs.isNotEmpty) {
      // Move to next song in playlist
      _currentSongIndex = (_currentSongIndex + 1) % _playlistSongs.length;

      // Check if we need to load more radio songs (when near end of playlist)
      if (_currentSongIndex >= _playlistSongs.length - 3 && _songData != null) {
        _loadMoreRadioSongs(_songData!.vId);
      }

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
    // Calculate the next index where the song should be inserted
    final insertIndex =
        (_currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length)
            ? _currentSongIndex + 1
            : _playlistSongs.length;

    // Check if song already exists in playlist, if so remove it first
    _playlistSongs.removeWhere((song) => song.vId == event.songData.vId);

    // Insert at the next index
    _playlistSongs.insert(insertIndex, event.songData);

    // Update current index if needed
    if (_currentSongIndex >= insertIndex) {
      _currentSongIndex++;
    }

    // Emit current state to trigger UI update
    if (_songData != null) {
      if (_isPlaying) {
        emit(PlayingState(
          songData: _songData!,
          volume: _currentVolume,
          isMuted: _isMute,
        ));
      } else {
        emit(PausedState(
          songData: _songData!,
          volume: _currentVolume,
          isMuted: _isMute,
        ));
      }
    }
  }

  void _removeFromPlaylist(
      RemoveFromPlaylistEvent event, Emitter<SongstreamState> emit) {
    // Find the index of the song to remove
    final indexToRemove = _playlistSongs.indexWhere(
      (song) => song.vId == event.videoId,
    );

    if (indexToRemove != -1) {
      // Remove the song from playlist
      _playlistSongs.removeAt(indexToRemove);

      // Update current index if needed
      if (_currentSongIndex > indexToRemove) {
        _currentSongIndex--;
      } else if (_currentSongIndex == indexToRemove &&
          _playlistSongs.isNotEmpty) {
        // If we removed the current song, stay at the same index (which now points to the next song)
        // Or if it was the last song, go to the previous one
        if (_currentSongIndex >= _playlistSongs.length) {
          _currentSongIndex = _playlistSongs.length - 1;
        }
      }

      // Emit current state to trigger UI update
      if (_songData != null) {
        if (_isPlaying) {
          emit(PlayingState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          ));
        } else {
          emit(PausedState(
            songData: _songData!,
            volume: _currentVolume,
            isMuted: _isMute,
          ));
        }
      }
    }
  }

//emit loading state with currentsong data
  void _loading(LoadingEvent event, Emitter<SongstreamState> emit) =>
      emit(LoadingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));

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
    _audioPlayer.pause();
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
  double get getCurrentVolume => _currentVolume;
  List<Songmodel> get getPlaylistSongs => List.unmodifiable(_playlistSongs);
  int get getCurrentSongIndex => _currentSongIndex;

  // New methods for upcoming songs  logic
  void _getUpcomingSongs(
      GetUpcomingSongsEvent event, Emitter<SongstreamState> emit) {
    List<Songmodel> upcomingSongs = [];

    if (_currentSongIndex >= 0 &&
        _currentSongIndex < _playlistSongs.length - 1) {
      upcomingSongs = _playlistSongs.sublist(_currentSongIndex + 1);
    } else if (_playlistSongs.isNotEmpty && _songData != null) {
      final currentSongIndex = _playlistSongs.indexWhere(
        (song) => song.vId == _songData!.vId,
      );
      if (currentSongIndex >= 0 &&
          currentSongIndex < _playlistSongs.length - 1) {
        upcomingSongs = _playlistSongs.sublist(currentSongIndex + 1);
      }
    }

    final isLoading = state is LoadingState;
    final shouldShowStartRadio =
        upcomingSongs.isEmpty && _playlistSongs.length <= 1 && !isLoading;

    emit(UpcomingSongsState(
      upcomingSongs: upcomingSongs,
      isLoading: isLoading,
      shouldShowStartRadio: shouldShowStartRadio,
    ));
  }

  void _shouldShowStartRadio(
      ShouldShowStartRadioEvent event, Emitter<SongstreamState> emit) {
    final upcomingSongs = getUpcomingSongs();
    final isLoading = state is LoadingState;
    final shouldShowStartRadio =
        upcomingSongs.isEmpty && _playlistSongs.length <= 1 && !isLoading;

    emit(UpcomingSongsState(
      upcomingSongs: upcomingSongs,
      isLoading: isLoading,
      shouldShowStartRadio: shouldShowStartRadio,
    ));
  }

  void _getUpcomingSongsState(
      GetUpcomingSongsStateEvent event, Emitter<SongstreamState> emit) {
    final upcomingSongs = getUpcomingSongs();
    final isLoading = state is LoadingState;
    final shouldShowStartRadio =
        upcomingSongs.isEmpty && _playlistSongs.length <= 1 && !isLoading;

    emit(UpcomingSongsState(
      upcomingSongs: upcomingSongs,
      isLoading: isLoading,
      shouldShowStartRadio: shouldShowStartRadio,
    ));
  }

  // Play a song from a playlist/album context
  // This keeps the playlist songs in the Up Next queue instead of generating radio songs
  Future<void> _playSongFromPlaylist(
      PlaySongFromPlaylistEvent event, Emitter<SongstreamState> emit) async {
    // Check if same song is already playing
    if (_songData != null &&
        event.songData.vId == _songData!.vId &&
        event.songData.isLocal == _songData!.isLocal) {
      // Same song, just restart from beginning
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;

      // Update playlist context
      _playlistSongs = event.playlistSongs.toSet().toList();
      _currentSongIndex = event.songIndex;

      emit(PlayingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));
      return;
    }

    // Reset audio player
    _resetAudioPlayer();

    // Set the playlist songs (no radio songs will be generated)
    _playlistSongs = event.playlistSongs.toSet().toList();
    _currentSongIndex = event.songIndex;
    _firstSongPlayedIndex = event.songIndex;

    // Clear stored quick picks so radio doesn't interfere
    _storeQuicksPicksList.clear();

    // Set the song data
    _songData = event.songData;

    emit(LoadingState(
      songData: _songData!,
      volume: _currentVolume,
      isMuted: _isMute,
    ));

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
        final qualityInfo = _dbInstance.getData;
        final songRawInfo = await _repository.getSongUrl(
            _songData!.vId, qualityInfo.audioQuality);
        final audioSource = LockCachingAudioSource(songRawInfo.url);
        await _audioPlayer.setAudioSource(audioSource);
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
      emit(PlayingState(
        songData: _songData!,
        volume: _currentVolume,
        isMuted: _isMute,
      ));

      // NOTE: We do NOT call _generateRadioSongs here
      // The Up Next will show playlist songs instead of radio songs
    } catch (e) {
      // Ignore "Loading interrupted" errors - they happen when user taps
      // multiple songs quickly and the restartable transformer cancels
      // the previous operation
      if (e.toString().contains('Loading interrupted')) {
        return;
      }
      emit(ErrorState(errorMessage: "Error fetching song: $e"));
    }
  }

  // Helper method to get upcoming songs
  List<Songmodel> getUpcomingSongs() {
    List<Songmodel> upcomingSongs = [];

    if (_currentSongIndex >= 0 &&
        _currentSongIndex < _playlistSongs.length - 1) {
      upcomingSongs = _playlistSongs.sublist(_currentSongIndex + 1);
    } else if (_playlistSongs.isNotEmpty && _songData != null) {
      final currentSongIndex = _playlistSongs.indexWhere(
        (song) => song.vId == _songData!.vId,
      );
      if (currentSongIndex >= 0 &&
          currentSongIndex < _playlistSongs.length - 1) {
        upcomingSongs = _playlistSongs.sublist(currentSongIndex + 1);
      }
    }

    return upcomingSongs;
  }
}
