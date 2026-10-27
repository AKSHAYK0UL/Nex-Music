class AudioPlayerStream {
  final Duration position;
  final Duration bufferPosition;
  final Duration totalDuration;

  AudioPlayerStream({
    required this.position,
    required this.bufferPosition,
    this.totalDuration = Duration.zero,
  });
}
