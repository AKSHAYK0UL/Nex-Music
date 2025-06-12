import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/route.dart';
import 'package:nex_music/main.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/overlay_audio_player.dart';
import 'package:nex_music/presentation/home/navbar/screen/navbar.dart';

ThumbnailQuality quality = ThumbnailQuality.low;

class MiniPlayer extends StatefulWidget {
  final double screenSize;

  const MiniPlayer({super.key, required this.screenSize});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final HiveDataBaseSingleton _dataBaseSingleton =
      HiveDataBaseSingleton.instance;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = await _dataBaseSingleton.getData;
      quality = data.thumbnailQuality;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.sizeOf(context).width < 451;
    return BlocBuilder<SongstreamBloc, SongstreamState>(
      builder: (context, state) {
        if (state is CloseMiniPlayerState) {
          return const SizedBox();
        }
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
              if (isSmallScreen) {
                Navigator.of(context).push(
                  slideTransitionRoute(
                    context: context,
                    songData: songData!,
                    route: SongMiniPlayerRoute.miniPlayerRoute,
                    quality: quality,
                  ),
                );
              } else {
                overlayEntry = OverlayEntry(
                  builder: (context) => OverlaySongPlayer(
                    key: overlayPlayerKey,
                    route: SongMiniPlayerRoute.miniPlayerRoute,
                    songData: songData!,
                    songIndex:
                        context.read<SongstreamBloc>().getFirstSongPlayedIndex,
                    quality: quality,
                    onClose: () {
                      overlayEntry?.remove();
                      overlayEntry = null;
                    },
                  ),
                );

                Overlay.of(context).insert(overlayEntry!);
              }
            },
            child: Stack(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                    side: BorderSide(color: backgroundColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.only(
                      left: widget.screenSize * 0.0356,
                      right: widget.screenSize * 0.00527),
                  leading: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(widget.screenSize * 0.0106),
                    child: Transform.scale(
                      scaleX:
                          quality == ThumbnailQuality.low && !songData.isLocal
                              ? 1
                              : 1.78,
                      scaleY: 1.0,
                      child: cacheImage(
                        imageUrl: songData.thumbnail,
                        width: widget.screenSize * 0.0755,
                        height: widget.screenSize * 0.0733,
                        islocal: songData.isLocal,
                      ),
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
                                  top: widget.screenSize * 0.0131,
                                  right: widget.screenSize * 0.0131),
                              height: widget.screenSize * 0.0395,
                              width: widget.screenSize * 0.0395,
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
                                size: widget.screenSize * 0.0520,
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
                          size: widget.screenSize * 0.0500,
                        ),
                        onPressed: () {
                          context
                              .read<SongstreamBloc>()
                              .add(PlayNextSongEvent());
                        },
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
                          minHeight: widget.screenSize * 0.00395,
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
