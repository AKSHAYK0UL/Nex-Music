import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/model/audioplayerstream.dart';

class StreamBuilderWidget extends StatefulWidget {
  final double screenSize;
  const StreamBuilderWidget({
    super.key,
    required this.screenSize,
  });

  @override
  State<StreamBuilderWidget> createState() => _StreamBuilderWidgetState();
}

class _StreamBuilderWidgetState extends State<StreamBuilderWidget> {
  late SongstreamBloc _songstreamBloc;
  late Stream<AudioPlayerStream> _stream;

  @override
  void initState() {
    super.initState();
    _songstreamBloc = context.read<SongstreamBloc>();
    _stream = _songstreamBloc.getAudioPlayerStreamData;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerStream>(
      stream: _stream,
      initialData: _songstreamBloc.currentAudioPlayerStream,
      builder: (context, snapshot) {
        final position =
            snapshot.data?.position ?? _songstreamBloc.currentPosition;
        final bufferedPosition = snapshot.data?.bufferPosition ??
            _songstreamBloc.currentBufferedPosition;
        final duration = _songstreamBloc.songDuration > Duration.zero
            ? _songstreamBloc.songDuration
            : (_songstreamBloc.songDurationOrParsed > Duration.zero
                ? _songstreamBloc.songDurationOrParsed
                : const Duration(seconds: 1));

        return RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: widget.screenSize * 0.0388),
            child: SizedBox(
              height: 48,
              child: ProgressBar(
                progress: position,
                buffered: bufferedPosition,
                total: duration,
                barHeight: 5,
                thumbRadius: 6,
                timeLabelLocation: TimeLabelLocation.below,
                timeLabelPadding: 6,
                baseBarColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.16),
                bufferedBarColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                progressBarColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.85),
                thumbColor: Theme.of(context).colorScheme.onSurface,
                timeLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  fontFeatures: const [
                    FontFeature.tabularFigures()
                  ], // Keeps numbers aligned
                ),
                onSeek: (value) {
                  _songstreamBloc.add(
                    SeekToEvent(position: value),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
