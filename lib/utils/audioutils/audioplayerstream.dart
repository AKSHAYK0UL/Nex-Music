import 'package:nex_music/model/audioplayerstream.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerStreamUtil {
  static Stream<AudioPlayerStream> audioPlayerStreamData({
    required Stream<Duration>? songPosition,
    required Stream<Duration>? bufferedPositionStream,
    Stream<Duration?>? durationStream,
  }) {
    final effectiveDurationStream =
        (durationStream ?? const Stream<Duration?>.empty())
            .startWith(null)
            .map((d) => d ?? Duration.zero);

    return Rx.combineLatest3(
      songPosition!,
      bufferedPositionStream!,
      effectiveDurationStream,
      (Duration position, Duration bufferPosition, Duration totalDuration) =>
          AudioPlayerStream(
        position: position,
        bufferPosition: bufferPosition,
        totalDuration: totalDuration,
      ),
    );
  }
}
