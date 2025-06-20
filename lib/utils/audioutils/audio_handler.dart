import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;
  SongstreamBloc? songstreamBloc;

  AudioPlayerHandler(this._player) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void setSongstreamBloc(SongstreamBloc bloc) {
    songstreamBloc = bloc;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

//TODO:
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {}

//TODO:
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {}

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  void setMediaItem(MediaItem mediaItem) {
    // First load the URL.
    // _player.setUrl(mediaItem.extras!['url']).then((_) {
    this.mediaItem.add(mediaItem);
    // playbackState
    //     .add(playbackState.value.copyWith(updatePosition: Duration.zero));
    // });
  }

//update the duration of the current song in control center
  void updateMediaItemDuration(Duration duration) {
    final currentMediaItem = mediaItem.value;
    if (currentMediaItem != null) {
      mediaItem.add(currentMediaItem.copyWith(duration: duration));
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop(); //  clears the notification
    mediaItem.add(null); //  clear media item
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _player.processingState.toAudioServiceState(),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    );
  }

  @override
  Future<void> skipToNext() async {
    songstreamBloc?.add(PlayNextSongEvent());
    print("SKIP TO NEXT CLICKED");
  }

  @override
  Future<void> skipToPrevious() async {
    songstreamBloc?.add(PlayPreviousSongEvent());
    print("SKIP TO PREVIOUS CLICKED");
  }
}

extension on ProcessingState {
  AudioProcessingState toAudioServiceState() {
    switch (this) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }
}
