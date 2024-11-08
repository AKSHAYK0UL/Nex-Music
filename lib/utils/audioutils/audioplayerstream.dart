import 'package:nex_music/model/audioplayerstream.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerStreamUtil {
  static Stream<AudioPlayerStream> audioPlayerStreamData(
      {required Stream<Duration>? songPosition,
      required Stream<Duration>? bufferedPositionStream}) {
    return Rx.combineLatest2(
      songPosition!,
      bufferedPositionStream!,
      (Duration position, Duration bufferPosition) => AudioPlayerStream(
        position: position,
        bufferPosition: bufferPosition,
      ),
    );
  }
}
