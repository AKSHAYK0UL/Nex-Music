// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';

// ignore: must_be_immutable
class DesktopAudioPlayer extends StatelessWidget {
  Songmodel songData;
  final SongMiniPlayerRoute route;
  final int songIndex;
  final ThumbnailQuality quality;
  DesktopAudioPlayer({
    super.key,
    required this.songData,
    required this.route,
    required this.songIndex,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize * 0.026, vertical: screenSize * 0.00725),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: textColor,
                  size: screenSize * 0.0493,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Share.share(
                      "https://music.youtube.com/watch?v=${songData.vId}");
                },
                child: Icon(
                  Icons.share,
                  color: textColor,
                  size: screenSize * 0.0330,
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
              child: BlocBuilder<SongstreamBloc, SongstreamState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (state is LoadingState) {
                    songData = state.songData;
                  }
                  if (state is PlayingState) {
                    songData = state.songData;
                  }
                  if (state is PausedState) {
                    songData = state.songData;
                  }
                  // return Center(
                  return Container(
                    // height: screenSize * 0.410,
                    // width: screenSize * 0.448,
                    // height: screenSize * 0.410,
                    // width: screenSize * 0.448,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenSize * 0.0131),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenSize * 0.0131),
                      child: Transform.scale(
                        scaleX: quality == ThumbnailQuality.low ? 1 : 1.78,
                        scaleY: 1.0,
                        child: cacheImage(
                          imageUrl: songData.thumbnail,
                          width: screenSize * 0.548,
                          height: screenSize * 0.510,
                        ),
                      ),
                    ),
                  );
                  // );
                },
              ),
            ),
            SizedBox(
              height: screenSize * 0.0380,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenSize * 0.356,
                        child: BlocBuilder<SongstreamBloc, SongstreamState>(
                          buildWhen: (previous, current) => previous != current,
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                animatedText(
                                  text: songData.songName,
                                  style:
                                      Theme.of(context).textTheme.titleLarge!,
                                ),
                                SizedBox(
                                  height: screenSize * 0.0050,
                                ),
                                animatedText(
                                  text: songData.artist.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium!,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.heart_fill,
                          color: textColor,
                          size: screenSize * 0.0395,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: screenSize * 0.0400,
            ),
            StreamBuilderWidget(
              screenSize: screenSize,
            ),
            SizedBox(
              height: screenSize * 0.0150,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<SongstreamBloc, SongstreamState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<SongstreamBloc>().add(MuteEvent());
                          },
                          icon: Icon(
                            context.read<SongstreamBloc>().getMuteStatus
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: textColor,
                            size: screenSize * 0.0400, //329
                          ),
                        ),
                        SizedBox(
                          width: screenSize * 0.0197,
                        ),
                        IconButton(
                          onPressed: () {
                            context
                                .read<SongstreamBloc>()
                                .add(PlayPreviousSongEvent());
                          },
                          icon: Icon(
                            Icons.skip_previous,
                            color: textColor,
                            size: screenSize * 0.0527,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  width: screenSize * 0.0131,
                ),
                Player(
                  songData: songData,
                  songIndex: songIndex,
                  screenSize: screenSize,
                  route: route,
                ),
                SizedBox(
                  width: screenSize * 0.0131,
                ),
                BlocBuilder<SongstreamBloc, SongstreamState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            context
                                .read<SongstreamBloc>()
                                .add(PlayNextSongEvent());
                          },
                          icon: Icon(
                            Icons.skip_next,
                            color: textColor,
                            size: screenSize * 0.0527,
                          ),
                        ),
                        SizedBox(
                          width: screenSize * 0.0197,
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<SongstreamBloc>().add(LoopEvent());
                          },
                          icon: Icon(
                            context.read<SongstreamBloc>().getLoopStatus
                                ? Icons.loop_outlined
                                : Icons.shuffle_outlined,
                            color: textColor,
                            size: screenSize * 0.0400,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: screenSize * 0.0240,
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.keyboard_arrow_up,
                  color: textColor,
                  size: screenSize * 0.0593,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
