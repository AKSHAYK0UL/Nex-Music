import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';

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
      final data = _dataBaseSingleton.getData;
      quality = data.thumbnailQuality;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final dividerColor = theme.dividerColor;
    const kAppleAccent = Color(0xFFFA2D48);

    return BlocBuilder<SongstreamBloc, SongstreamState>(
      builder: (context, state) {
        if (state is CloseMiniPlayerState) {
          return const SizedBox();
        }
        Songmodel? songData;

        if (state is PlayingState) {
          songData = state.songData;
        } else if (state is PausedState) {
          songData = state.songData;
        } else if (state is LoadingState) {
          songData = state.songData;
        }

        if (songData != null) {
          void navigateToAudioPlayer() {
            context.push(
              RouterPath.audioPlayerRoute,
              extra: {
                "songindex": context.read<SongstreamBloc>().getFirstSongPlayedIndex,
                'songdata': songData!,
                'route': SongMiniPlayerRoute.miniPlayerRoute,
                "quality": quality,
              },
            );
          }
          return GestureDetector(
            onTap: navigateToAudioPlayer,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                navigateToAudioPlayer();
              }
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: dividerColor, width: 0.5),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: cacheImage(
                                imageUrl: songData.thumbnail,
                                width: 48,
                                height: 48,
                                islocal: songData.isLocal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              animatedText(
                                text: songData.songName,
                                style: TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              animatedText(
                                text: songData.artist.name,
                                style: TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state is LoadingState)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: titleColor,
                                ),
                              )
                            else
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  state is PlayingState
                                      ? CupertinoIcons.pause_fill
                                      : CupertinoIcons.play_fill,
                                  color: titleColor,
                                  size: 26,
                                ),
                                onPressed: () {
                                  context.read<SongstreamBloc>().add(PlayPauseEvent());
                                },
                              ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                CupertinoIcons.forward_fill,
                                color: titleColor,
                                size: 26,
                              ),
                              onPressed: () {
                                context.read<SongstreamBloc>().add(PlayNextSongEvent());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<Duration>(
                    stream: context.read<SongstreamBloc>().songPosition,
                    builder: (context, snapshot) {
                      final duration = context.read<SongstreamBloc>().songDuration;
                      final position = snapshot.data ?? Duration.zero;
                      if (duration.inMilliseconds == 0) return const SizedBox();
                      final sliderValue = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: sliderValue,
                          valueColor: const AlwaysStoppedAnimation<Color>(kAppleAccent),
                          backgroundColor: Colors.grey.shade400,
                          minHeight: 2,
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