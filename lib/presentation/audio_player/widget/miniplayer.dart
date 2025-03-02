import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/route.dart';
import 'package:nex_music/model/songmodel.dart';

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
        } else if (state is LoadingState) {
          songData = state.songData;
        }

        // Show mini player UI if song data exists
        if (songData != null) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                slideTransitionRoute(
                  context: context,
                  songData: songData!,
                  route: SongMiniPlayerRoute.miniPlayerRoute,
                ),
              );
            },
            child: Stack(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                    side: BorderSide(color: backgroundColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.only(
                      left: screenSize * 0.0356, right: screenSize * 0.00527),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(screenSize * 0.0106),
                    child: cacheImage(
                      imageUrl: songData.thumbnail,
                      width: screenSize * 0.0755,
                      height: screenSize * 0.0733,
                    ),
                  ),
                  title: animatedText(
                    text: songData.songName,
                    style: Theme.of(context).textTheme.titleSmall!,
                  ),
                  subtitle: animatedText(
                    text: songData.artist.name,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      state is LoadingState
                          ? Container(
                              margin: EdgeInsets.only(
                                  top: screenSize * 0.0131,
                                  right: screenSize * 0.0131),
                              height: screenSize * 0.0395,
                              width: screenSize * 0.0395,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: textColor,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                state is PlayingState
                                    ? CupertinoIcons.pause_circle_fill
                                    : CupertinoIcons.play_circle_fill,
                                color: textColor,
                                size: screenSize * 0.0520,
                              ),
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayPauseEvent());
                              },
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: textColor,
                          size: screenSize * 0.0500,
                        ),
                        onPressed: () {
                          context
                              .read<SongstreamBloc>()
                              .add(PlayNextSongEvent());
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.close,
                      //     color: Colors.red,
                      //     size: screenSize * 0.0500,
                      //   ),
                      //   onPressed: () {
                      //     context
                      //         .read<SongstreamBloc>()
                      //         .add(CloseMiniPlayerEvent());
                      //   },
                      // ),
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

                    // Ensure duration is not zero or null
                    if (duration.inMilliseconds == 0 || position == null) {
                      return const SizedBox(); // Return an empty box if no valid data
                    }

                    // Safely calculate the slider value
                    double sliderValue = 0.0;
                    if (duration.inMilliseconds > 0 &&
                        position.inMilliseconds >= 0) {
                      sliderValue =
                          position.inMilliseconds / duration.inMilliseconds;
                    }

                    // If sliderValue exceeds 1 (e.g., duration is longer than the position), cap it at 1
                    sliderValue = sliderValue.clamp(0.0, 1.0);

                    return Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: LinearProgressIndicator(
                          value: sliderValue,
                          backgroundColor: textColor,
                          color: accentColor,
                          minHeight: screenSize * 0.00395,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
