
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/core/widget/song_options_menu.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/helper_function/routefunc/artistview_route.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';
import 'package:nex_music/presentation/audio_player/widget/volume_slider.dart';
import 'package:nex_music/presentation/audio_player/widget/sleep_timer_widget.dart';
import 'package:nex_music/presentation/audio_player/widget/sleep_timer_indicator.dart';
import 'package:nex_music/presentation/audio_player/widget/upcoming_songs_bottom_sheet.dart';
import 'package:nex_music/service/sleep_timer_service.dart';

// Custom widget to detect upward swipes without interfering with Dismissible
class _SwipeUpDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeUp;

  const _SwipeUpDetector({
    required this.child,
    required this.onSwipeUp,
  });

  @override
  State<_SwipeUpDetector> createState() => _SwipeUpDetectorState();
}

class _SwipeUpDetectorState extends State<_SwipeUpDetector> {
  double? _startY;
  bool _isUpwardSwipe = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _startY = event.position.dy;
        _isUpwardSwipe = false;
      },
      onPointerMove: (event) {
        if (_startY != null) {
          final delta = event.position.dy - _startY!;
          // If moving upward (negative delta) mark as upward swipe
          if (delta < -10) {
            _isUpwardSwipe = true;
          }
          // If moving downward (positive delta) reset to allow Dismissible to work
          if (delta > 10) {
            _isUpwardSwipe = false;
            _startY = null; // Reset to stop tracking
          }
        }
      },
      onPointerUp: (event) {
        if (_startY != null && _isUpwardSwipe) {
          final delta = event.position.dy - _startY!;
          // If the swipe was upward and significant, trigger the callback
          if (delta < -100) {
            widget.onSwipeUp();
          }
        }
        _startY = null;
        _isUpwardSwipe = false;
      },
      child: widget.child,
    );
  }
}


class AudioPlayerScreen extends StatefulWidget {
  static const routeName = "/audioplayer";
  final Map<String,dynamic> routeData; 
  const AudioPlayerScreen({super.key,required this.routeData});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  //  Add a GlobalKey to track the position of the menu button
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    // Set status bar style for audio player
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final routeData =
      //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      Songmodel songData =widget. routeData["songdata"] as Songmodel;
      context.read<FavoritesBloc>().add(IsFavoritesEvent(vId: songData.vId));

      // Initialize sleep timer service
      SleepTimerService.instance.initialize(
        context.read<SleepTimerBloc>(),
        context.read<SongstreamBloc>(),
        context,
      );
    });
    super.initState();
  }

  void _showMoreOptions(
      BuildContext context, Songmodel songData, double screenSize) {
    // 1. Find the button's position and size
    final RenderBox? renderBox =
        _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    //  Determine Position Logic
    // If button is in the lower half of screen, show menu ABOVE it.
    final bool showAbove = offset.dy > screenHeight / 2;

    // Configuration
    const double gap = 6.0; // Space between button and menu
    const double padding = 16.0; // Safe distance from screen edges
    const double menuWidth = 250.0;

    //  Calculate Horizontal Position
    // Align the right edge of the menu with the right edge of the button
    double leftPosition = offset.dx + buttonSize.width - menuWidth;

    // Clamp horizontal position so it doesn't go off-screen
    if (leftPosition + menuWidth > screenWidth - padding) {
      leftPosition = screenWidth - menuWidth - padding;
    } else if (leftPosition < padding) {
      leftPosition = padding;
    }

    showModalBottomSheet(
            useRootNavigator: true,

      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent, 
      builder: (context) {
        return GestureDetector(
          // Tap outside to close
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  // Horizontal Alignment
                  left: leftPosition,
                  width: menuWidth,

                  // Vertical Alignment Logic:
                  // If showing ABOVE: Anchor the BOTTOM of the menu to the top of the button
                  bottom: showAbove ? (screenHeight - offset.dy) + gap : null,

                  // If showing BELOW: Anchor the TOP of the menu to the bottom of the button
                  top: showAbove ? null : offset.dy + buttonSize.height + gap,

                  child: ConstrainedBox(
                    // Responsive: Limit height so it doesn't go off-screen
                    constraints: BoxConstraints(
                      maxHeight: showAbove
                          ? offset.dy - (padding * 2)
                          : screenHeight -
                              (offset.dy + buttonSize.height) -
                              (padding * 2),
                    ),
                    // Material wrapper ensures shadow and proper rendering
                    child: Material(
                      color: Colors.transparent,
                      child: SingleChildScrollView(
                        // Allows scrolling if the menu is too tall for the remaining screen space
                        child: SongOptionsMenu(
                          songData: songData,
                          screenSize: screenSize,
                          tabRouteENUM: TabRouteENUM.other,
                          menuType: SongMenuType.audioPlayer,
                          onTimerTap: () {
                            Navigator.pop(context); // Close menu
                            _showSleepTimerDialog(context); // Show timer
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    // final routeData =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    Songmodel songData = widget.routeData["songdata"] as Songmodel;
    final route = widget.routeData["route"] as SongMiniPlayerRoute;
    final songIndex = widget.routeData["songindex"] as int;
    final quality = widget.routeData["quality"] as ThumbnailQuality;

    return BlocListener<DownloadBloc, DownloadState>(
      listener: (context, state) {
        if (state is DownloadErrorState) {
          showSnackbar(context, state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(

          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            Dismissible(
              key: const Key('audio_player_dismiss'),
              direction: DismissDirection.down,
              onDismissed: (_) {
                // Navigator.of(context).pop();
                context.pop();
              },
              background: Container(color: Colors.transparent),
              secondaryBackground: Container(color: Colors.transparent),
              child: SafeArea(
                child: _SwipeUpDetector(
                  onSwipeUp: () => _showUpcomingSongsBottomSheet(context),
                  child: ColoredBox(
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(height: screenSize * 0.01),
                        // --- 1. Top Grab Handle ---
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
            
                        const Spacer(flex: 1),
            
                      // ---  Album Art ---
                      BlocBuilder<SongstreamBloc, SongstreamState>(
                        buildWhen: (previous, current) => previous != current,
                        builder: (context, state) {
                          // Get current song from state first
                          Songmodel currentSongData = songData;
                          if (state is LoadingState) {
                            currentSongData = state.songData;
                            // Update favorites check with current song's vId
                            context
                                .read<FavoritesBloc>()
                                .add(IsFavoritesEvent(vId: currentSongData.vId));
                          } else if (state is PlayingState) {
                            currentSongData = state.songData;
                            // Update favorites check with current song's vId
                            context
                                .read<FavoritesBloc>()
                                .add(IsFavoritesEvent(vId: currentSongData.vId));
                          } else if (state is PausedState) {
                            currentSongData = state.songData;
                            // Update favorites check with current song's vId
                            context
                                .read<FavoritesBloc>()
                                .add(IsFavoritesEvent(vId: currentSongData.vId));
                          } else {
                            // Fallback to route data if state doesn't have songData
                            context
                                .read<FavoritesBloc>()
                                .add(IsFavoritesEvent(vId: songData.vId));
                          }
                          return Container(
                            height: screenWidth * 0.88,
                            width: screenWidth * 0.88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  cacheImage(
                                      imageUrl: currentSongData.thumbnail,
                                      width: screenWidth * 0.88,
                                      height: screenWidth * 0.88,
                                      islocal: currentSongData.isLocal),
                                  // Sleep Timer Indicator positioned at bottom center
                                  const Positioned(
                                    bottom: 5,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: SleepTimerIndicator(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            
                      const Spacer(flex: 1),
            
                      // --- Title, Artist & Like Button ---
                      Padding(
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                          padding:
                            EdgeInsets.only(left: screenWidth * 0.08,right: screenWidth * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<SongstreamBloc, SongstreamState>(
                                    builder: (context, state) {
                                      // Get current song from state
                                      Songmodel currentSongData = songData;
                                      if (state is LoadingState) {
                                        currentSongData = state.songData;
                                      } else if (state is PlayingState) {
                                        currentSongData = state.songData;
                                      } else if (state is PausedState) {
                                        currentSongData = state.songData;
                                      }
                                      return animatedText(
                                        text: currentSongData.songName,
                                        style: const TextStyle(
                                          fontFamily: 'Serif',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  BlocBuilder<SongstreamBloc, SongstreamState>(
                                    builder: (context, state) {
                                      // Get current song from state
                                      Songmodel currentSongData = songData;
                                      if (state is LoadingState) {
                                        currentSongData = state.songData;
                                      } else if (state is PlayingState) {
                                        currentSongData = state.songData;
                                      } else if (state is PausedState) {
                                        currentSongData = state.songData;
                                      }
                                      return animatedText(
                                        text: currentSongData.artist.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<SongstreamBloc, SongstreamState>(
                              buildWhen: (previous, current) => previous != current,
                              builder: (context, songState) {
                                // Get current song from state
                                Songmodel currentSongData = songData;
                                if (songState is LoadingState) {
                                  currentSongData = songState.songData;
                                } else if (songState is PlayingState) {
                                  currentSongData = songState.songData;
                                } else if (songState is PausedState) {
                                  currentSongData = songState.songData;
                                }
                                return BlocBuilder<FavoritesBloc, FavoritesState>(
                                  buildWhen: (previous, current) {
                                    // Rebuild when song changes or favorite state changes
                                    if (previous is IsFavoritesState &&
                                        current is IsFavoritesState) {
                                      return previous.vId != current.vId ||
                                          previous.isFavorites != current.isFavorites;
                                    }
                                    return previous != current;
                                  },
                                  builder: (context, favState) {
                                    bool isFavorite = false;
                                    if (favState is IsFavoritesState &&
                                        favState.vId == currentSongData.vId) {
                                      isFavorite = favState.isFavorites;
                                    }
                                    return IconButton(
                                      onPressed: () {
                                        if (isFavorite) {
                                          context.read<FavoritesBloc>().add(
                                              RemoveFromFavoritesEvent(
                                                  vId: currentSongData.vId));
                                        } else {
                                          context.read<FavoritesBloc>().add(
                                              AddToFavoritesEvent(
                                                  song: currentSongData));
                                        }
                                      },
                                      icon: Icon(
                                        isFavorite
                                            ? CupertinoIcons.heart_fill
                                            : CupertinoIcons.heart,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey.shade600,
                                        size: 28,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 20),
            
                      // --- 4. Progress Bar ---
                      StreamBuilderWidget(screenSize: screenSize),
                      const SizedBox(height: 7),
            
                      // --- 5. Controls (Prev, Play, Next) ---
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: screenWidth * 0.13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              iconSize: 40,
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayPreviousSongEvent());
                              },
                              icon: const Icon(CupertinoIcons.backward_fill),
                            ),
                            BlocBuilder<SongstreamBloc, SongstreamState>(
                              buildWhen: (previous, current) => previous != current,
                              builder: (context, state) {
                                // Get current song from state
                                Songmodel currentSongData = songData;
                                if (state is LoadingState) {
                                  currentSongData = state.songData;
                                } else if (state is PlayingState) {
                                  currentSongData = state.songData;
                                } else if (state is PausedState) {
                                  currentSongData = state.songData;
                                }
                                return SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Player(
                                      songData: currentSongData,
                                      songIndex: songIndex,
                                      screenSize: screenSize,
                                      route: route,
                                      isPlaylist: widget.routeData["isplaylist"] ?? false,
                                      // widget
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              iconSize: 40,
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayNextSongEvent());
                              },
                              icon: const Icon( CupertinoIcons.forward_fill),
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 30),
            
                      // --- 6. Volume Slider ---
                      VolumeSlider(screenWidth: screenWidth),
            
                      const Spacer(flex: 2),
            
                      // --- 7. Bottom Actions ---
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: screenSize * 0.024,
                            left: screenWidth * 0.12,
                            right: screenWidth * 0.12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                artistViewRoute(
                                    context,
                                    ArtistModel(
                                        artist: songData.artist,
                                        thumbnail: songData.thumbnail));
                              },
                              icon: Icon(
                                CupertinoIcons.person_crop_circle_fill,
                                color: Colors.red.withValues(alpha:0.8),
                                size: 28.5,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                               
                              },
                              icon: Icon(
                                Icons.lyrics_outlined,
                                color: Colors.red.withValues(alpha:0.8),
                                size: 28.5,
                              ),
                            ),
                            BlocBuilder<SongstreamBloc, SongstreamState>(
                              buildWhen: (previous, current) =>
                                  previous != current,
                              builder: (context, state) {
                                return IconButton(
                                  onPressed: () {
                                    context
                                        .read<SongstreamBloc>()
                                        .add(LoopEvent());
                                  },
                                  icon: Icon(
                                    context
                                            .read<SongstreamBloc>()
                                            .getLoopStatus
                                        ? FontAwesomeIcons.repeat
                                        : FontAwesomeIcons.shuffle,
                                    color: Colors.red.withValues(alpha:0.8),
                                    size: 23,
                                  ),
                                );
                              },
                            ),
                            // Download button with progress indicator
                            //  Wrap the Menu/Download button in a Container with the GlobalKey
                            Container(
                              key: _menuButtonKey,
                              child: BlocBuilder<SongstreamBloc, SongstreamState>(
                                buildWhen: (previous, current) => previous != current,
                                builder: (context, songState) {
                                  // Get current song from state
                                  Songmodel currentSongData = songData;
                                  if (songState is LoadingState) {
                                    currentSongData = songState.songData;
                                  } else if (songState is PlayingState) {
                                    currentSongData = songState.songData;
                                  } else if (songState is PausedState) {
                                    currentSongData = songState.songData;
                                  }
                                  return BlocBuilder<DownloadBloc, DownloadState>(
                                    builder: (context, state) {
                                      final isDownloading =
                                          state is DownloadPercantageStatusState;
            
                                      if (isDownloading) {
                                        return StreamBuilder<double>(
                                          stream: state.percentageStream,
                                          builder: (context, snapshot) {
                                            final progress = snapshot.data ?? 0.0;
                                            return GestureDetector(
                                              onTap: () => _showMoreOptions(
                                                  context, currentSongData, screenSize),
                                              child: SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Circular progress indicator
                                                    CircularProgressIndicator(
                                                      value: progress / 100,
                                                      strokeWidth: 3,
                                                      backgroundColor:
                                                          Colors.grey.shade300,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<Color>(
                                                        Colors.red.withValues(alpha:0.6),
                                                      ),
                                                    ),
                                                    // Cloud download icon
                                                    Icon(
                                                      CupertinoIcons.cloud_download,
                                                      color:
                                                          Colors.red.withValues(alpha:0.6),
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return IconButton(
                                          onPressed: () => _showMoreOptions(
                                              context, currentSongData, screenSize),
                                          icon: Icon(
                                            FontAwesomeIcons.list,
                                            color: Colors.red.withValues(alpha:0.8),
                                            size: 24,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showUpcomingSongsBottomSheet(context),
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: SleepTimerWidget(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpcomingSongsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // Prevent tap from closing when tapping on the sheet
                child: const UpcomingSongsBottomSheet(),
              ),
            ),
          ),
        );
      },
    );
  }
}
