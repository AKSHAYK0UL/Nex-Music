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
  final AudioPlayer _audioPlayer = AudioPlayer();

  SongstreamBloc(this.repository) : super(SongstreamInitial()) {
    on<GetSongStreamEvent>(_getSongUrl);
    on<PlayPauseEvent>(_togglePlayPause);
  }

  Future<void> _getSongUrl(
      GetSongStreamEvent event, Emitter<SongstreamState> emit) async {
    emit(LoadingState());
    songData = event.songData;

    try {
      final songUrl = await repository.getSongUrl(event.songData.vId);
      _currentSongUrl = songUrl.toString();
      await _audioPlayer.setUrl(_currentSongUrl).then((_) {
        _audioPlayer.play();
      }).catchError((_) {
        emit(ErrorState(errorMessage: "Error loading song"));
        return;
      });
      _audioPlayer.play();
      _isPlaying = true;

      emit(
        PlayingState(
          songData: songData!,
        ),
      );
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }

  void _togglePlayPause(PlayPauseEvent event, Emitter<SongstreamState> emit) {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
      emit(PausedState(
        songData: songData!,
      ));
    } else {
      _audioPlayer.play();
      _isPlaying = true;
      emit(PlayingState(
        songData: songData!,
      ));
    }
  }
}
