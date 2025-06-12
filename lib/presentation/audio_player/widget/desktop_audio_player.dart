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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
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
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenSize * 0.0131),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenSize * 0.0131),
                            child: Transform.scale(
                              scaleX:
                                  quality == ThumbnailQuality.low ? 1 : 1.78,
                              scaleY: 1.0,
                              child: cacheImage(
                                imageUrl: songData.thumbnail,
                                width: screenSize * 0.548,
                                height: screenSize * 0.510,
                                islocal: songData.isLocal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              color: secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: 250,
                                width: 400,
                                decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildOptionButton(
                                            context,
                                            () {},
                                            Icons.download,
                                            "Download",
                                            screenSize),
                                        buildOptionButton(context, () {},
                                            Icons.person, "Artist", screenSize),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildOptionButton(
                                            context,
                                            () {},
                                            CupertinoIcons.heart_fill,
                                            "Like",
                                            screenSize),
                                        buildOptionButton(context, () async {
                                          await Share.share(
                                              "https://music.youtube.com/watch?v=${songData.vId}");
                                        }, Icons.share, "Share", screenSize),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildOptionButton(context, () {
                                          context
                                              .read<SongstreamBloc>()
                                              .add(MuteEvent());
                                        },
                                            context
                                                    .read<SongstreamBloc>()
                                                    .getMuteStatus
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            context
                                                    .read<SongstreamBloc>()
                                                    .getMuteStatus
                                                ? "Mute"
                                                : "Sound",
                                            screenSize),
                                        buildOptionButton(context, () {
                                          context
                                              .read<SongstreamBloc>()
                                              .add(LoopEvent());
                                        },
                                            context
                                                    .read<SongstreamBloc>()
                                                    .getLoopStatus
                                                ? Icons.loop_outlined
                                                : Icons.shuffle_outlined,
                                            context
                                                    .read<SongstreamBloc>()
                                                    .getLoopStatus
                                                ? "Loop"
                                                : "Shuffle",
                                            screenSize),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: screenSize * 0.550,
                              child: animatedText(
                                  text: "  ${songData.songName}",
                                  style:
                                      Theme.of(context).textTheme.titleLarge!),
                            ),
                            SizedBox(
                              width: screenSize * 0.550,
                              child: animatedText(
                                text: "  ${songData.artist.name}",
                                style: Theme.of(context).textTheme.titleMedium!,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(
            height: screenSize * 0.0600,
          ),
          StreamBuilderWidget(
            screenSize: screenSize,
          ),
          SizedBox(
            height: screenSize * 0.0150,
          ),
          //butttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<SongstreamBloc, SongstreamState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  return IconButton(
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
                  return IconButton(
                    onPressed: () {
                      context.read<SongstreamBloc>().add(PlayNextSongEvent());
                    },
                    icon: Icon(
                      Icons.skip_next,
                      color: textColor,
                      size: screenSize * 0.0527,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildOptionButton(BuildContext context, VoidCallback onTap,
    IconData icon, String label, double screenSize) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 180,
      child: Chip(
        deleteIcon: Icon(
          icon,
          color: textColor,
          size: screenSize * 0.0370,
        ),
        padding: const EdgeInsets.all(10),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: backgroundColor),
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(
                icon,
                color: textColor,
                size: screenSize * 0.0370,
              ),
            ),
            Text(
              label.padRight(8, " "),
              style: Theme.of(context).textTheme.titleSmall,
            )
          ],
        ),
      ),
    ),
  );
}
