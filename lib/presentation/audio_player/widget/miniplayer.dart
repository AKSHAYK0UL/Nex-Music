import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

class MiniPlayer extends StatelessWidget {
  final double screenSize;

  const MiniPlayer({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongstreamBloc, SongstreamState>(
      builder: (context, state) {
        Songmodel? songData;

        // Handle PlayingState or PausedState
        if (state is PlayingState) {
          songData = state.songData;
        } else if (state is PausedState) {
          songData = state.songData;
        }

        // Show mini player UI if song data exists
        if (songData != null) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AudioPlayerScreen.routeName,
                  arguments: {
                    "songdata": songData,
                    "route": SongMiniPlayerRoute.miniPlayerRoute
                  });
            },
            child: Hero(
              tag: songData.vId,
              child: Stack(
                children: [
                  Container(
                    width: 385,
                    height: 75,
                    padding: EdgeInsets.only(
                      top: screenSize * 0.012,
                      bottom: screenSize * 0.012,
                      left: 18,
                      right: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: secondaryColor),
                      ),
                      color: backgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 75,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: songData.thumbnail,
                                  fit: BoxFit.fill,
                                  placeholder: (_, __) => Image.asset(
                                    "assets/imageplaceholder.png",
                                    fit: BoxFit.fill,
                                  ),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    "assets/imageplaceholder.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenSize * 0.015),
                            SizedBox(
                              width: 185,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  animatedText(
                                    text: songData.songName,
                                    style:
                                        Theme.of(context).textTheme.titleSmall!,
                                  ),
                                  animatedText(
                                    text: songData.artist.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                state is PlayingState
                                    ? Icons.pause_circle
                                    : Icons.play_circle_fill,
                                color: textColor,
                                size: 35,
                              ),
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayPauseEvent());
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 32,
                              ),
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(CloseMiniPlayerEvent());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: context.read<SongstreamBloc>().songPosition,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      final duration =
                          context.read<SongstreamBloc>().songDuration;
                      final position = snapshot.data;
                      double sliderValue = 0.0;
                      if (position != null) {
                        sliderValue =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      return Positioned(
                        bottom: 0,
                        child: SizedBox(
                          width: 380,
                          child: LinearProgressIndicator(
                            value: sliderValue,
                            backgroundColor: Colors.white,
                            color: Colors.red,
                            minHeight: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
