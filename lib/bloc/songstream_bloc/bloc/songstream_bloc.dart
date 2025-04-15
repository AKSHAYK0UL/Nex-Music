//------------------------------------------------------------------------------
//working fine for android not for windows
// import 'dart:async';
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
//   bool _isPlaying = false; //default false
//   Songmodel? _songData;
//   Duration songDuration = Duration.zero;
//   Stream<Duration>? songPosition;
//   Stream<Duration>? bufferedPositionStream;
//   bool _isLooping = false; //default false
//   List<Songmodel> _playlistSongs = [];
//   int _currentSongIndex = -1; // Keep track of the current song in the playlist
//   int _firstSongPlayedIndex =
//       0; //store the index of first song played in the playlist
//   bool _isMute = false; //default false
//   double _storedVolume = 0.0;
//   bool _songLoaded = false; //default false
//   // late CancelableOperation<void> _currentOperation;

//   List<Songmodel> _storeQuicksPicksList = [];
//   final AudioPlayerHandler _audioPlayerHandler;

//   SongstreamBloc(
//     this._repository,
//     this._audioPlayer,
//     this._audioPlayerHandler,
//     this._dbRepository,
//     this._dbInstance,
//   ) : super(SongstreamInitial()) {
//     on<GetSongStreamEvent>(_getSongUrl,
//         transformer: restartable<GetSongStreamEvent>());
//     on<PlayPauseEvent>(_togglePlayPause);
//     on<CloseMiniPlayerEvent>(_closeMiniPlayer);
//     on<SongCompletedEvent>(_onSongCompleted);
//     on<SeekToEvent>(_seekTo);
//     on<PauseEvent>(_togglePause);
//     on<PlayEvent>(_togglePlay);
//     on<LoopEvent>(_toggleLoop);
//     on<GetSongPlaylistEvent>(_songsPlaylist);
//     on<GetSongUrlOnShuffleEvent>(_getSongUrlOnShuffle,
//         transformer: restartable<GetSongUrlOnShuffleEvent>());
//     on<LoadingEvent>(_loading);
//     on<ResetPlaylistEvent>(_resetPlaylist);
//     on<CleanPlaylistEvent>(_cleanSongsPlaylist);
//     on<MuteEvent>(_togglemute);
//     on<UpdateUIEvent>(_updateUIFromBackground);
//     on<PlayNextSongEvent>(_playNextSong);
//     on<PlayPreviousSongEvent>(_playPreviousSong);
//     on<AddToPlayNextEvent>(_addToPlayNext);
//     on<DisposeAudioPlayerEvent>(_disposeAudioPlayer);
//     on<StoreQuickPicksSongsEvent>(_storeQuickPicks);

//     songPosition = _audioPlayer.positionStream;
//     bufferedPositionStream = _audioPlayer.bufferedPositionStream;

//     _initializeAudioPlayerListeners();
//   }

//   // Combine the audio player streams into one
//   Stream<AudioPlayerStream> get getAudioPlayerStreamData {
//     return AudioPlayerStreamUtil.audioPlayerStreamData(
//         songPosition: songPosition,
//         bufferedPositionStream: bufferedPositionStream);
//   }

//   void _initializeAudioPlayerListeners() {
//     _audioPlayer.durationStream.listen((duration) {
//       songDuration = duration ?? Duration.zero; // Handle null duration
//       if (duration != null) {
//         _audioPlayerHandler.updateMediaItemDuration(
//             duration); //update duration in control center
//       }
//     });

//     _audioPlayer.playerStateStream.listen(
//       (streamState) {
//         if (streamState.processingState == ProcessingState.completed) {
//           add(SongCompletedEvent());
//         }

//         if (streamState.processingState == ProcessingState.buffering ||
//             streamState.processingState == ProcessingState.loading) {
//           add(LoadingEvent());
//         }

//         if (_songLoaded &&
//             streamState.processingState != ProcessingState.buffering &&
//             streamState.processingState != ProcessingState.loading) {
//           if (streamState.playing && state is! PlayingState) {
//             add(PlayEvent());
//           } else if (!streamState.playing && state is! PausedState) {
//             add(PauseEvent());
//           }
//         }
//       },
//     );
//   }

//   //Update UI when returning back from the Background / recent apps
//   void _updateUIFromBackground(
//       UpdateUIEvent event, Emitter<SongstreamState> emit) {
//     if (state.runtimeType != CloseMiniPlayerState) {
//       if (_isPlaying) {
//         add(PlayEvent());
//       } else {
//         add(PauseEvent());
//       }
//     }
//   }

//   // Fetch the song URL and handle playback
//   Future<void> _getSongUrl(
//       GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
//     _resetAudioPlayer();
//     emit(LoadingState(songData: event.songData));
//     _songData = event.songData;

//     _firstSongPlayedIndex = event.songIndex;
//     _currentSongIndex++;
//     _playlistSongs.insert(_currentSongIndex,
//         _songData!); //add the current song to the loaded playlist
//     _audioPlayerHandler.setMediaItem(
//       MediaItem(
//         id: _songData!.vId,
//         title: _songData!.songName,
//         artist: _songData!.artist.name,
//         artUri: Uri.parse(_songData!.thumbnail),
//         duration: songDuration,
//       ),
//     );
//     try {
//       final qualityInfo = await _dbInstance.getData;
//       final songUrl = await _repository.getSongUrl(
//           _songData!.vId, qualityInfo.audioQuality);

//       await _audioPlayer.setUrl(songUrl.toString());

//       _audioPlayer.play();
//       _isPlaying = true;
//       _songLoaded = true;

//       //add to db recent played collection
//       _dbRepository.addToRecentPlayedCollection(_songData!);

//       emit(PlayingState(songData: _songData!));
//     } catch (e) {
//       emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
//     }
//   }

// //when on shuffle
//   Future<void> _getSongUrlOnShuffle(
//       GetSongUrlOnShuffleEvent event, Emitter<SongstreamState> emit) async {
//     _resetAudioPlayerWhenOnShuffle();
//     emit(LoadingState(songData: event.songData));
//     _songData = event.songData;
//     _audioPlayerHandler.setMediaItem(MediaItem(
//       id: _songData!.vId,
//       title: _songData!.songName,
//       artist: _songData!.artist.name,
//       artUri: Uri.parse(_songData!.thumbnail),
//       duration: songDuration,
//     ));
//     try {
//       final qualityInfo = await _dbInstance.getData;

//       final songUrl = await _repository.getSongUrl(
//           _songData!.vId, qualityInfo.audioQuality);

//       await _audioPlayer.setUrl(songUrl.toString());

//       _audioPlayer.play();
//       _isPlaying = true;
//       _songLoaded = true;
// //add to db recent played collection
//       _dbRepository.addToRecentPlayedCollection(_songData!);

//       emit(PlayingState(songData: _songData!));
//     } catch (e) {
//       emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
//     }
//   }

// //add to play next

//   void _addToPlayNext(AddToPlayNextEvent event, Emitter<SongstreamState> emit) {
//     final insertIndex =
//         _currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length
//             ? _currentSongIndex + 1
//             : _playlistSongs.length;

//     _playlistSongs.insert(insertIndex, event.songData);

//     // If inserting before current song, adjust current index
//     if (_currentSongIndex >= insertIndex) {
//       _currentSongIndex++;
//     }
//   }

// //seek forward/backward
//   void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
//     _audioPlayer.seek(event.position);
//   }

//   //Get loop status
//   bool get getLoopStatus {
//     return _isLooping;
//   }

//   // get current song Data
//   Songmodel get getCurrentSongData {
//     return _songData!;
//   }

// //first song Played index
//   int get getFirstSongPlayedIndex {
//     return _firstSongPlayedIndex;
//   }

//   //get mute status
//   bool get getMuteStatus {
//     return _isMute;
//   }

//   //Mute Audio Player
//   void _togglemute(MuteEvent event, Emitter<SongstreamState> emit) {
//     final volume = _audioPlayer.volume;
//     _isMute = !_isMute;
//     if (volume != 0.0) {
//       _storedVolume = volume;
//       _audioPlayer.setVolume(0.0);
//     } else {
//       _audioPlayer.setVolume(_storedVolume);
//     }
//     if (_isPlaying) {
//       emit(PlayingState(songData: _songData!));
//     } else {
//       emit(PausedState(songData: _songData!));
//     }
//   }

//   //add loading stata
//   void _loading(LoadingEvent event, Emitter<SongstreamState> emit) {
//     emit(LoadingState(songData: _songData!));
//   }

//   // Pause Event
//   void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
//     _isPlaying = false;
//     _audioPlayer.pause();
//     emit(PausedState(songData: _songData!));
//   }

//   // Play Event
//   void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
//     _isPlaying = true;
//     _audioPlayer.play();
//     emit(PlayingState(songData: _songData!));
//   }

//   // Toggle between play and pause
//   void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
//     if (_isPlaying) {
//       add(PauseEvent());
//     } else {
//       add(PlayEvent());
//     }
//   }

//   void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
//     if ((_currentSongIndex + 1) < _playlistSongs.length) {
//       _currentSongIndex++;
//     } else {
//       _currentSongIndex = 0;
//     }
//     add(GetSongUrlOnShuffleEvent(
//       songData: _playlistSongs[_currentSongIndex],
//     ));
//   }

//   void _playPreviousSong(
//       PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
//     if ((_currentSongIndex - 1) >= 0) {
//       _currentSongIndex--;
//     } else {
//       _currentSongIndex = _playlistSongs.length - 1;
//     }
//     add(GetSongUrlOnShuffleEvent(
//       songData: _playlistSongs[_currentSongIndex],
//     ));
//   }

//   // Close the mini player
//   void _closeMiniPlayer(
//       CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) async {
//     // _audioPlayerHandler.onNotificationDeleted();
//     // _audioPlayerHandler.stop();
//     await _audioPlayer.pause();
//     _isPlaying = false;
//     emit(CloseMiniPlayerState());
//   }

// //reset audio player
//   void _resetAudioPlayer() {
//     _songLoaded = false;
//     if (_isPlaying) {
//       _audioPlayer.pause();
//       _isPlaying = false;
//     }
//     songDuration = Duration.zero;

//     _audioPlayer.seek(Duration.zero); // Reset position
//   }

// //reset audio player on shuffle
//   void _resetAudioPlayerWhenOnShuffle() {
//     _songLoaded = false;

//     _isPlaying = false;
//     songDuration = Duration.zero;
//     _audioPlayer.seek(Duration.zero); // Reset position
//   }

//   // Handle when the song is completed
//   void _onSongCompleted(
//       SongCompletedEvent event, Emitter<SongstreamState> emit) {
//     if (_playlistSongs.isNotEmpty && !_isLooping) {
//       if (_firstSongPlayedIndex == 0 &&
//           _currentSongIndex + 2 < _playlistSongs.length) {
//         _currentSongIndex += 2;
//         _firstSongPlayedIndex = _currentSongIndex;
//       } else if (_firstSongPlayedIndex != 0 &&
//           _currentSongIndex + 1 < _playlistSongs.length) {
//         _currentSongIndex++;
//       } else {
//         _currentSongIndex = 0;
//       }
//       add(GetSongUrlOnShuffleEvent(
//         songData: _playlistSongs[_currentSongIndex],
//       ));
//     }
//   }

//   // Toggle loop state
//   void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
//     _isLooping = !_isLooping;
//     final currentLoopMode = _audioPlayer.loopMode;

//     if (currentLoopMode == LoopMode.off) {
//       _audioPlayer.setLoopMode(LoopMode.one); // Set loop mode
//     } else {
//       _audioPlayer.setLoopMode(LoopMode.off); // Disable loop mode
//     }
//     if (_isPlaying) {
//       emit(PlayingState(songData: _songData!));
//     } else {
//       emit(PausedState(songData: _songData!));
//     }
//   }

//   // Handle playlist songs
//   void _songsPlaylist(
//       GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//     _playlistSongs = event.songlist.toSet().toList();
//   }

//   //Reset Playlist
//   void _resetPlaylist(ResetPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _playlistSongs = [];
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//   }

// //clean the playlist
//   void _cleanSongsPlaylist(
//       CleanPlaylistEvent event, Emitter<SongstreamState> emit) {
//     _playlistSongs = [];
//     _playlistSongs = _storeQuicksPicksList;
//     _currentSongIndex = -1;
//     _firstSongPlayedIndex = 0;
//   }

//   //store Quicks Picks
//   void _storeQuickPicks(
//       StoreQuickPicksSongsEvent event, Emitter<SongstreamState> emit) {
//     _storeQuicksPicksList = event.quickPicks;
//   }

//   void _disposeAudioPlayer(
//       DisposeAudioPlayerEvent event, Emitter<SongstreamState> emit) {
//     _audioPlayer.dispose();
//   }

// //close
//   @override
//   Future<void> close() {
//     _audioPlayer.dispose();
//     return super.close();
//   }
// }

//----------------------------------------------------------------------------------
//made changes to work on windows

import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
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
  final AudioPlayerHandler _audioPlayerHandler;

  SongstreamBloc(
    this._repository,
    this._audioPlayer,
    this._audioPlayerHandler,
    this._dbRepository,
    this._dbInstance,
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
    on<UpdateUIEvent>(_updateUIFromBackground);
    on<PlayNextSongEvent>(_playNextSong);
    on<PlayPreviousSongEvent>(_playPreviousSong);
    on<AddToPlayNextEvent>(_addToPlayNext);
    on<DisposeAudioPlayerEvent>(_disposeAudioPlayer);
    on<StoreQuickPicksSongsEvent>(_storeQuickPicks);

    songPosition = _audioPlayer.positionStream;
    bufferedPositionStream = _audioPlayer.bufferedPositionStream;

    _initializeAudioPlayerListeners();
  }

  Stream<AudioPlayerStream> get getAudioPlayerStreamData =>
      AudioPlayerStreamUtil.audioPlayerStreamData(
          songPosition: songPosition,
          bufferedPositionStream: bufferedPositionStream);

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

// Refresh the UI when the app returns from the dead [background or recent apps].
  void _updateUIFromBackground(
      UpdateUIEvent event, Emitter<SongstreamState> emit) {
    if (state.runtimeType != CloseMiniPlayerState) {
      _isPlaying ? add(PlayEvent()) : add(PauseEvent());
    }
  }

// Grab the song URL, update the "Recently Played" list and start playing.
// (I know the function name isn’t ideal)
  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayer();
    emit(LoadingState(songData: event.songData));
    _songData = event.songData;
    _firstSongPlayedIndex = event.songIndex;
    _currentSongIndex++;
    _playlistSongs.insert(_currentSongIndex, _songData!);

    _audioPlayerHandler.setMediaItem(MediaItem(
      id: _songData!.vId,
      title: _songData!.songName,
      artist: _songData!.artist.name,
      artUri: Uri.parse(_songData!.thumbnail),
      duration: songDuration,
    ));

    try {
      final qualityInfo = await _dbInstance.getData;
      final songUrl = await _repository.getSongUrl(
          _songData!.vId, qualityInfo.audioQuality);

      await _audioPlayer.setUrl(songUrl.toString());
      if (Platform.isWindows) {
        await _audioPlayer.load();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
      _dbRepository.addToRecentPlayedCollection(_songData!);
      emit(PlayingState(songData: _songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

// Do exactly what [_getSongUrl] does, but with extra spice shuffle mode activated.
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
      duration: songDuration,
    ));

    try {
      final qualityInfo = await _dbInstance.getData;
      final songUrl = await _repository.getSongUrl(
          _songData!.vId, qualityInfo.audioQuality);

      await _audioPlayer.setUrl(songUrl.toString());
      if (Platform.isWindows) {
        await _audioPlayer.load();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _audioPlayer.play();
      _isPlaying = true;
      _songLoaded = true;
      _dbRepository.addToRecentPlayedCollection(_songData!);
      emit(PlayingState(songData: _songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: "Error fetching song URL: $e"));
    }
  }

//add the song to the PlayNext playlist
  void _addToPlayNext(AddToPlayNextEvent event, Emitter<SongstreamState> emit) {
    final insertIndex =
        (_currentSongIndex >= 0 && _currentSongIndex < _playlistSongs.length)
            ? _currentSongIndex + 1
            : _playlistSongs.length;

    _playlistSongs.insert(insertIndex, event.songData);
    if (_currentSongIndex >= insertIndex) _currentSongIndex++;
  }

//
  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

//
  bool get getLoopStatus => _audioPlayer.loopMode == LoopMode.one;
  //
  Songmodel? get getCurrentSongData => _songData;
  //
  int get getFirstSongPlayedIndex => _firstSongPlayedIndex;
  //
  bool get getMuteStatus => _isMute;

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

//emit loading state with currentsong data
  void _loading(LoadingEvent event, Emitter<SongstreamState> emit) =>
      emit(LoadingState(songData: _songData!));
//emit pause state
  void _togglePause(PauseEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = false;
    _audioPlayer.pause();
    emit(PausedState(songData: _songData!));
  }

//emit play state
  void _togglePlay(PlayEvent event, Emitter<SongstreamState> emit) {
    _isPlaying = true;
    _audioPlayer.play();
    emit(PlayingState(songData: _songData!));
  }

//emit pause/play state
  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) =>
      _isPlaying ? add(PauseEvent()) : add(PlayEvent());

//move to next played song in the list
  void _playNextSong(PlayNextSongEvent event, Emitter<SongstreamState> emit) {
    _currentSongIndex = (_currentSongIndex + 1) < _playlistSongs.length
        ? _currentSongIndex + 1
        : 0;
    add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
  }

//move to previous played song in the list
  void _playPreviousSong(
      PlayPreviousSongEvent event, Emitter<SongstreamState> emit) {
    _currentSongIndex = (_currentSongIndex - 1) >= 0
        ? _currentSongIndex - 1
        : _playlistSongs.length - 1;
    add(GetSongUrlOnShuffleEvent(songData: _playlistSongs[_currentSongIndex]));
  }

//not in use
  Future<void> _closeMiniPlayer(
      CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) async {
    await _audioPlayer.pause();
    _isPlaying = false;
    emit(CloseMiniPlayerState());
  }

//reset the player
  void _resetAudioPlayer() {
    _songLoaded = false;
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero);
  }

//reset the player when on shuffle mode
  void _resetAudioPlayerWhenOnShuffle() {
    _songLoaded = false;
    _isPlaying = false;
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero);
  }

//Runs every time a song finishes playing.
/*
if(addToPlayNextQueue.isNotEmpty){
final firstSong = queue.first();//get first song
queue.removeFirst()
 add(GetSongUrlOnShuffleEvent(
          songData: firstSong);

}




 */
  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
    // if (_audioPlayer.loopMode == LoopMode.one) {
    if (_audioPlayer.loopMode == LoopMode.one && Platform.isWindows) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      // }
    } else if (_playlistSongs.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex + 1) < _playlistSongs.length
          ? _currentSongIndex + 1
          : 0;
      add(GetSongUrlOnShuffleEvent(
          songData: _playlistSongs[_currentSongIndex]));
    }
  }

//toople loop and shuffle
  void _toggleLoop(LoopEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.setLoopMode(
        _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one);
    emit(_isPlaying
        ? PlayingState(songData: _songData!)
        : PausedState(songData: _songData!));
  }

//include playlist songs, quickspicks, add to playnext
  void _songsPlaylist(
      GetSongPlaylistEvent event, Emitter<SongstreamState> emit) {
    _currentSongIndex = -1;
    _firstSongPlayedIndex = 0;
    _playlistSongs = event.songlist.toSet().toList();
  }

//
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

//store quickPicks [now called Discover]
  void _storeQuickPicks(
          StoreQuickPicksSongsEvent event, Emitter<SongstreamState> emit) =>
      _storeQuicksPicksList = event.quickPicks;
// dispose audio player
  void _disposeAudioPlayer(
          DisposeAudioPlayerEvent event, Emitter<SongstreamState> emit) =>
      _audioPlayer.dispose();
  //close
  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
