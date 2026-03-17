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

  @override
  void initState() {
    super.initState();
    _songstreamBloc = context.read<SongstreamBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerStream>(
      stream: _songstreamBloc.getAudioPlayerStreamData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 20);
        }

        final position = snapshot.data?.position;
        final bufferedPosition = snapshot.data?.bufferPosition;
        final duration = _songstreamBloc.songDuration;

        return RepaintBoundary(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.screenSize * 0.0388),
                child: ProgressBar(
                  progress: position ?? Duration.zero,
                  buffered: bufferedPosition ?? Duration.zero,
                  total: duration,

                 
                  barHeight: 5,
                  thumbRadius: 6,
                  timeLabelLocation: TimeLabelLocation.below,
                  timeLabelPadding: 10,

                  baseBarColor: Colors.grey.shade400,
                  bufferedBarColor: Colors.grey.shade500,
                  progressBarColor: Colors.black87,
                  thumbColor: Colors.black,

                  timeLabelTextStyle: const TextStyle(
                    color: Colors.black, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w600, 
                    fontFeatures: [
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
            ],
          ),
        );
      },
    );
  }
}
