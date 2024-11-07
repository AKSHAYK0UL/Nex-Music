import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'songstream_event.dart';
part 'songstream_state.dart';

class SongstreamBloc extends Bloc<SongstreamEvent, SongstreamState> {
  final Repository repository;
  bool _isPlaying = false;
  Songmodel? songData;
  String _currentSongUrl = '';
  Duration songDuration = Duration.zero;
  Stream<Duration>? songPosition;

  final AudioPlayer _audioPlayer = AudioPlayer();

  SongstreamBloc(this.repository) : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl);
    on<PlayPauseEvent>(_togglePlayPause);
    on<CloseMiniPlayerEvent>(_closeMiniPlayer);
    on<SongCompletedEvent>(_onSongCompleted);
    on<SeekToEvent>(_seekTo);

    songPosition = _audioPlayer.positionStream;

    // Initialize audio player listeners
    _initializeAudioPlayerListeners();
  }

  void _initializeAudioPlayerListeners() {
    _audioPlayer.durationStream.listen((duration) {
      songDuration = duration!; // Update song duration when available
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Dispatch SongCompletedEvent when song completes
        add(SongCompletedEvent());
        return;
      }
    });
  }

  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    _resetAudioPlayer();

    emit(LoadingState());
    songData = event.songData;
    songDuration = Duration.zero;
    _audioPlayer.seek(Duration.zero);

    try {
      final songUrl = await repository.getSongUrl(event.songData.vId);
      _currentSongUrl = songUrl.toString();
      await _audioPlayer.setUrl(_currentSongUrl).then((_) {
        _audioPlayer.play();
        _isPlaying = true;
      }).catchError((_) {
        emit(ErrorState(errorMessage: "Error loading song"));
        return;
      });

      emit(PlayingState(songData: songData!));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

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

  void _closeMiniPlayer(
      CloseMiniPlayerEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    emit(CloseMiniPlayerState());
  }

  void _onSongCompleted(
      SongCompletedEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.pause();
    _isPlaying = false;

    // Emit paused state after song completion
    emit(PausedState(songData: songData!));
  }

  void _seekTo(SeekToEvent event, Emitter<SongstreamState> emit) {
    _audioPlayer.seek(event.position);
  }

// Function
  void _resetAudioPlayer() {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    }
  }
}
