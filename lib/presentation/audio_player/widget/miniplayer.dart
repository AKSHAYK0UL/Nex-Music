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
    const kAppleWhite = Color(0xFFF9F9F9); 
    const kAppleDivider = Color(0xFFE5E5EA); 
    const kAppleTitleColor = Color(0xFF000000); 
    const kAppleSubtitleColor = Color(0xFF8E8E93); 
    const kAppleAccent = Color(0xFFFA2D48); 

    return BlocBuilder<SongstreamBloc, SongstreamState>(
      builder: (context, state) {
        if (state is CloseMiniPlayerState) {
          return const SizedBox();
        }
        Songmodel? songData;

        // Handle States
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
            // onTap: () {
            //   pushWithoutNavBar(
            //     context,
            //     slideTransitionRoute(
            //         context: context,
            //         songData: songData!,
            //         route: SongMiniPlayerRoute.miniPlayerRoute,
            //         quality: quality),
            //   );
            // },
            onTap: navigateToAudioPlayer,
            onVerticalDragEnd: (details) {
              // PrimaryVelocity < 0 indicates an upward swipe
              if (details.primaryVelocity! < 0) {
                navigateToAudioPlayer();
              }
            },
            child: Container(
              height: 64, 
              decoration: const BoxDecoration(
                color: kAppleWhite,
                border: Border(
                  top: BorderSide(
                    color: kAppleDivider,
                    width: 0.5, 
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Album Art with Shadow
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              child: Transform.scale(
                                scale: 1.0, // Clean scaling
                                child: cacheImage(
                                  imageUrl: songData.thumbnail,
                                  width: 48,
                                  height: 48,
                                  islocal: songData.isLocal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 14),

                        // Title and Artist
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              animatedText(
                                text: songData.songName,
                                style: const TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: kAppleTitleColor,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              animatedText(
                                text: songData.artist.name,
                                style: const TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: kAppleSubtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play/Pause Button
                            if (state is LoadingState)
                               Container(
                                width: 20,
                                height: 20,
                                margin:const  EdgeInsets.symmetric(horizontal: 15),
                                child:const CircularProgressIndicator(
                                  strokeWidth:4,
                                  color: kAppleTitleColor,
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
                                  color: kAppleTitleColor, 
                                  size: 26,
                                ),
                                onPressed: () {
                                  context
                                      .read<SongstreamBloc>()
                                      .add(PlayPauseEvent());
                                },
                              ),
                            
                            // const SizedBox(width: 1),

                            // Next Button
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                CupertinoIcons.forward_fill,
                                color: kAppleTitleColor, 
                                size: 26,
                              ),
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayNextSongEvent());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Progress Bar
                  StreamBuilder<Duration>(
                    stream: context.read<SongstreamBloc>().songPosition,
                    builder: (context, snapshot) {
                      final duration =
                          context.read<SongstreamBloc>().songDuration;
                      final position = snapshot.data ?? Duration.zero;

                      if (duration.inMilliseconds == 0) {
                        return const SizedBox();
                      }

                      double sliderValue = 0.0;
                      if (position.inMilliseconds > 0) {
                        sliderValue = (position.inMilliseconds /
                                duration.inMilliseconds)
                            .clamp(0.0, 1.0);
                      }

                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: sliderValue,
                          // backgroundColor: Colors.transparent, // Clean look
                          valueColor:const AlwaysStoppedAnimation<Color>(kAppleAccent),
                           backgroundColor: Colors.grey.shade400,
                          color: kAppleSubtitleColor.withValues(alpha: 0.4), // Subtle grey progress
                          minHeight: 2, // Very thin
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