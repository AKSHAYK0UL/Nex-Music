import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/model/volume_info_model.dart';

class VolumeSlider extends StatelessWidget {
  final double screenWidth;

  const VolumeSlider({
    super.key,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: BlocBuilder<SongstreamBloc, SongstreamState>(
        buildWhen: (previous, current) {
          final prevInfo = VolumeInfoModel.fromState(previous);
          final currInfo = VolumeInfoModel.fromState(current);

          // Only rebuild if volume or mute status actually changes
          return prevInfo != currInfo;
        },
        builder: (context, state) {
          final volumeInfo = VolumeInfoModel.fromState(state);

          return Row(
            spacing: 3,
            children: [
              GestureDetector(
                onTap: () => context.read<SongstreamBloc>().add(MuteEvent()),
                child: Icon(
                  volumeInfo.isMuted || volumeInfo.volume == 0.0
                      ? CupertinoIcons.speaker_slash_fill
                      : volumeInfo.volume < 0.3
                          ? CupertinoIcons.speaker_1_fill
                          : volumeInfo.volume < 0.7
                              ? CupertinoIcons.speaker_2_fill
                              : CupertinoIcons.speaker_3_fill,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: volumeInfo.volume < 0.5
                        ? Colors.green
                        : volumeInfo.volume < 0.75
                            ? Colors.orange
                            : Colors.red,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: volumeInfo.volume < 0.5
                        ? Colors.green
                        : volumeInfo.volume < 0.75
                            ? Colors.orange
                            : Colors.red,
                  ),
                  child: Slider(
                    value: volumeInfo.isMuted ? 0.0 : volumeInfo.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      context
                          .read<SongstreamBloc>()
                          .add(SetVolumeEvent(volume: value));
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
