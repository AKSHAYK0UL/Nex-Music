import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/model/audioplayerstream.dart';

class StreamBuilderWidget extends StatelessWidget {
  final double screenSize;
  const StreamBuilderWidget({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerStream>(
      stream: context.read<SongstreamBloc>().getAudioPlayerStreamData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        final position = snapshot.data?.position;
        final bufferedPosition = snapshot.data?.bufferPosition;
        final duration = context.read<SongstreamBloc>().songDuration;

        double sliderValue = 0.0;
        double bufferValue = 0.0;

        if (position != null && duration.inMilliseconds > 0) {
          sliderValue = (position.inMilliseconds / duration.inMilliseconds)
              .clamp(0.0, 1.0);
        }

        if (bufferedPosition != null && duration.inMilliseconds > 0) {
          bufferValue =
              (bufferedPosition.inMilliseconds / duration.inMilliseconds)
                  .clamp(0.0, 1.0);
        }

        return Column(
          children: [
            StatefulBuilder(
              builder: (context, setState) => Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenSize * 0.0325),
                    child: LinearProgressIndicator(
                      value: bufferValue,
                      color: Colors.grey,
                      backgroundColor: textColor,
                    ),
                  ),
                  Slider(
                    value: sliderValue,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      final seekToPosition = Duration(
                        milliseconds: (value * duration.inMilliseconds).toInt(),
                      );
                      context
                          .read<SongstreamBloc>()
                          .add(SeekToEvent(position: seekToPosition));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
              child: BlocBuilder<SongstreamBloc, SongstreamState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(timeFormate(position?.inSeconds ?? 0)),
                      Text(timeFormate(duration.inSeconds)),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
