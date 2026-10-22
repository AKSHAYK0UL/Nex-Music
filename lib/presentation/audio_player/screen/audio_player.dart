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
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';
import 'package:nex_music/presentation/audio_player/widget/volume_slider.dart';
import 'package:nex_music/presentation/audio_player/widget/sleep_timer_widget.dart';
import 'package:nex_music/presentation/audio_player/widget/sleep_timer_indicator.dart';
import 'package:nex_music/presentation/audio_player/widget/upcoming_songs_bottom_sheet.dart';
import 'package:nex_music/presentation/audio_player/widget/music_lyrics_view.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:nex_music/service/sleep_timer_service.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';

// Custom widget to detect upward swipes reliably
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
  double? _startX;
  double _lowestY = 0;
  DateTime? _startTime;
  DateTime? _lastTriggerTime;

  void _trigger() {
    final now = DateTime.now();
    if (_lastTriggerTime != null &&
        now.difference(_lastTriggerTime!).inMilliseconds < 450) {
      return;
    }
    _lastTriggerTime = now;
    widget.onSwipeUp();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _startY = event.position.dy;
        _startX = event.position.dx;
        _lowestY = event.position.dy;
        _startTime = DateTime.now();
      },
      onPointerMove: (event) {
        if (_startY != null) {
          if (event.position.dy > _lowestY) {
            _lowestY = event.position.dy;
          }
        }
      },
      onPointerUp: (event) {
        if (_startY != null && _startX != null && _startTime != null) {
          final dyTotal = event.position.dy - _startY!;
          final dyFromLowest = event.position.dy - _lowestY;
          final dx = (event.position.dx - _startX!).abs();
          final elapsedMs =
              DateTime.now().difference(_startTime!).inMilliseconds;

          final upwardDist = (-dyTotal).clamp(0.0, double.infinity);
          final upwardFromLowest = (-dyFromLowest).clamp(0.0, double.infinity);
          final effectiveUpward =
              upwardFromLowest > upwardDist ? upwardFromLowest : upwardDist;

          final velocity =
              elapsedMs > 0 ? (effectiveUpward / elapsedMs) * 1000 : 0.0;
          final isVertical = effectiveUpward > dx * 0.75;

          // Trigger on deliberate swipe, fast flick, or quick upward stroke
          if (isVertical &&
              (effectiveUpward > 40 ||
                  (effectiveUpward > 20 && velocity > 220) ||
                  (effectiveUpward > 25 && elapsedMs < 350))) {
            _trigger();
          }
        }
        _startY = null;
        _startX = null;
        _startTime = null;
      },
      onPointerCancel: (_) {
        _startY = null;
        _startX = null;
        _startTime = null;
      },
      child: widget.child,
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  static const routeName = "/audioplayer";
  final Map<String, dynamic> routeData;
  const AudioPlayerScreen({super.key, required this.routeData});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  //  Add a GlobalKey to track the position of the menu button
  final GlobalKey _menuButtonKey = GlobalKey();
  final ValueNotifier<bool> _isLyricsView = ValueNotifier<bool>(false);
  bool _isUpcomingSheetOpen = false;
  late final AnimationController _lyricsAnimController;
  late final Animation<Offset> _lyricsSlideAnimation;

  @override
  void initState() {
    _lyricsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 230),
    );
    _lyricsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _lyricsAnimController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn,
      ),
    );

    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Songmodel songData = widget.routeData["songdata"] as Songmodel;
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

  @override
  void dispose() {
    _lyricsAnimController.dispose();
    _isLyricsView.dispose();
    super.dispose();
  }

  void _openLyrics() {
    if (_lyricsAnimController.isAnimating) return;
    _isLyricsView.value = true;
    _lyricsAnimController.forward();
  }

  void _closeLyrics() {
    if (_lyricsAnimController.isAnimating) return;
    _lyricsAnimController.reverse().then((_) {
      if (mounted) {
        _isLyricsView.value = false;
      }
    });
  }

  void _showMoreOptions(
      BuildContext context, Songmodel songData, double screenSize,
      {GlobalKey? buttonKey}) {
    //  Find the button's position and size
    final keyToUse = buttonKey ?? _menuButtonKey;
    final RenderBox? renderBox =
        keyToUse.currentContext?.findRenderObject() as RenderBox?;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Configuration
    const double gap = 6.0; // Space between button and menu
    const double padding = 16.0; // Safe distance from screen edges
    const double menuWidth = 250.0;

    final double leftPosition;
    final double? bottomPos;
    final double? topPos;
    final double maxHeight;

    if (renderBox != null) {
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final Size buttonSize = renderBox.size;
      final bool showAbove = offset.dy > screenHeight / 2;
      double calcLeft = offset.dx + buttonSize.width - menuWidth;
      if (calcLeft + menuWidth > screenWidth - padding) {
        calcLeft = screenWidth - menuWidth - padding;
      } else if (calcLeft < padding) {
        calcLeft = padding;
      }
      leftPosition = calcLeft;
      bottomPos = showAbove ? (screenHeight - offset.dy) + gap : null;
      topPos = showAbove ? null : offset.dy + buttonSize.height + gap;
      maxHeight = showAbove
          ? offset.dy - (padding * 2)
          : screenHeight - (offset.dy + buttonSize.height) - (padding * 2);
    } else {
      leftPosition = screenWidth - menuWidth - padding;
      topPos = MediaQuery.paddingOf(context).top + 60;
      bottomPos = null;
      maxHeight = screenHeight - topPos - (padding * 2);
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
          onTap: () => context.pop(),
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
                  bottom: bottomPos,
                  top: topPos,

                  child: ConstrainedBox(
                    // Responsive: Limit height so it doesn't go off-screen
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
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
                            context.pop();
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

  Songmodel _getCurrentlyPlayingSong(BuildContext context) {
    final state = context.read<SongstreamBloc>().state;
    if (state is LoadingState) return state.songData;
    if (state is PlayingState) return state.songData;
    if (state is PausedState) return state.songData;
    return widget.routeData["songdata"] as Songmodel;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    Songmodel songData = _getCurrentlyPlayingSong(context);
    final route = widget.routeData["route"] as SongMiniPlayerRoute;
    final songIndex = widget.routeData["songindex"] as int;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_lyricsAnimController.isAnimating) return;
        if (_isLyricsView.value || _lyricsAnimController.value > 0) {
          _closeLyrics();
          return;
        }
        context.pop();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isLyricsView,
        builder: (context, isLyrics, child) {
          final overlayStyle = isLyrics
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.black,
                )
              : (isDark
                  ? SystemUiOverlayStyle.light.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: theme.scaffoldBackgroundColor,
                    )
                  : SystemUiOverlayStyle.dark.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: theme.scaffoldBackgroundColor,
                    ));
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: child!,
          );
        },
        child: MultiBlocListener(
          listeners: [
            BlocListener<DownloadBloc, DownloadState>(
              listener: (context, state) {
                if (state is DownloadErrorState) {
                  showSnackbar(context, state.errorMessage);
                }
              },
            ),
            BlocListener<SongstreamBloc, SongstreamState>(
              listenWhen: (previous, current) {
                String? prevId;
                String? currId;
                if (previous is LoadingState) prevId = previous.songData.vId;
                if (previous is PlayingState) prevId = previous.songData.vId;
                if (previous is PausedState) prevId = previous.songData.vId;
                if (current is LoadingState) currId = current.songData.vId;
                if (current is PlayingState) currId = current.songData.vId;
                if (current is PausedState) currId = current.songData.vId;
                return currId != null && currId != prevId;
              },
              listener: (context, state) {
                Songmodel? currentSong;
                if (state is LoadingState) currentSong = state.songData;
                if (state is PlayingState) currentSong = state.songData;
                if (state is PausedState) currentSong = state.songData;
                if (currentSong != null) {
                  context
                      .read<FavoritesBloc>()
                      .add(IsFavoritesEvent(vId: currentSong.vId));
                }
                setState(() {});
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ValueListenableBuilder<bool>(
              valueListenable: _isLyricsView,
              builder: (context, isLyrics, child) {
                return Dismissible(
                  key: const Key('audio_player_dismiss'),
                  direction:
                      isLyrics ? DismissDirection.none : DismissDirection.down,
                  resizeDuration: null,
                  movementDuration: const Duration(milliseconds: 100),
                  dismissThresholds: const {DismissDirection.down: 0.15},
                  onDismissed: (_) {
                    context.pop();
                  },
                  background: Container(color: Colors.transparent),
                  secondaryBackground: Container(color: Colors.transparent),
                  child: child!,
                );
              },
              child: SizedBox.expand(
                child: ColoredBox(
                  color: theme.scaffoldBackgroundColor,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SafeArea(
                        child: _SwipeUpDetector(
                          onSwipeUp: () =>
                              _showUpcomingSongsBottomSheet(context),
                          child: Column(
                              children: [
                                SizedBox(height: screenSize * 0.01),
                                //  Top Grab Handle
                                Center(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => context.pop(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 20.0),
                                      child: Container(
                                        width: 40,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(flex: 1),

                                // Album Art
                                BlocBuilder<SongstreamBloc, SongstreamState>(
                                  buildWhen: (previous, current) {
                                    String? prevId;
                                    String? currId;
                                    if (previous is LoadingState) prevId = previous.songData.vId;
                                    if (previous is PlayingState) prevId = previous.songData.vId;
                                    if (previous is PausedState) prevId = previous.songData.vId;
                                    if (current is LoadingState) currId = current.songData.vId;
                                    if (current is PlayingState) currId = current.songData.vId;
                                    if (current is PausedState) currId = current.songData.vId;
                                    return currId != null && currId != prevId;
                                  },
                                  builder: (context, state) {
                                    // Get current song from state first
                                    Songmodel currentSongData = songData;
                                    if (state is LoadingState) {
                                      currentSongData = state.songData;
                                    } else if (state is PlayingState) {
                                      currentSongData = state.songData;
                                    } else if (state is PausedState) {
                                      currentSongData = state.songData;
                                    }
                                    final quality = HiveDataBaseSingleton
                                        .instance.getData.thumbnailQuality;
                                    final highResUrl = currentSongData.isLocal
                                        ? currentSongData.thumbnail
                                        : getHighResThumbnail(
                                            currentSongData.thumbnail,
                                            videoId: currentSongData.vId,
                                            quality: quality,
                                          );

                                    return Container(
                                      height: screenWidth * 0.88,
                                      width: screenWidth * 0.88,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
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
                                                imageUrl: highResUrl,
                                                fallbackUrl:
                                                    currentSongData.thumbnail,
                                                width: screenWidth * 0.88,
                                                height: screenWidth * 0.88,
                                                islocal:
                                                    currentSongData.isLocal),
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

                                //  Title, Artist & Like Button
                                Padding(
                                  // padding:
                                  //     EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.08,
                                      right: screenWidth * 0.05),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            BlocBuilder<SongstreamBloc,
                                                SongstreamState>(
                                              buildWhen: (previous, current) {
                                                String? prevId;
                                                String? currId;
                                                if (previous is LoadingState) prevId = previous.songData.vId;
                                                if (previous is PlayingState) prevId = previous.songData.vId;
                                                if (previous is PausedState) prevId = previous.songData.vId;
                                                if (current is LoadingState) currId = current.songData.vId;
                                                if (current is PlayingState) currId = current.songData.vId;
                                                if (current is PausedState) currId = current.songData.vId;
                                                return currId != null && currId != prevId;
                                              },
                                              builder: (context, state) {
                                                // Get current song from state
                                                Songmodel currentSongData =
                                                    songData;
                                                if (state is LoadingState) {
                                                  currentSongData =
                                                      state.songData;
                                                } else if (state
                                                    is PlayingState) {
                                                  currentSongData =
                                                      state.songData;
                                                } else if (state
                                                    is PausedState) {
                                                  currentSongData =
                                                      state.songData;
                                                }
                                                return animatedText(
                                                  text:
                                                      currentSongData.songName,
                                                  style: TextStyle(
                                                    fontFamily: 'Serif',
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 4),
                                            BlocBuilder<SongstreamBloc,
                                                SongstreamState>(
                                              buildWhen: (previous, current) {
                                                String? prevId;
                                                String? currId;
                                                if (previous is LoadingState) prevId = previous.songData.vId;
                                                if (previous is PlayingState) prevId = previous.songData.vId;
                                                if (previous is PausedState) prevId = previous.songData.vId;
                                                if (current is LoadingState) currId = current.songData.vId;
                                                if (current is PlayingState) currId = current.songData.vId;
                                                if (current is PausedState) currId = current.songData.vId;
                                                return currId != null && currId != prevId;
                                              },
                                              builder: (context, state) {
                                                // Get current song from state
                                                Songmodel currentSongData =
                                                    songData;
                                                if (state is LoadingState) {
                                                  currentSongData =
                                                      state.songData;
                                                } else if (state
                                                    is PlayingState) {
                                                  currentSongData =
                                                      state.songData;
                                                } else if (state
                                                    is PausedState) {
                                                  currentSongData =
                                                      state.songData;
                                                }
                                                return animatedText(
                                                  text: currentSongData
                                                      .artist.name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      BlocBuilder<SongstreamBloc,
                                          SongstreamState>(
                                        buildWhen: (previous, current) =>
                                            previous != current,
                                        builder: (context, songState) {
                                          // Get current song from state
                                          Songmodel currentSongData = songData;
                                          if (songState is LoadingState) {
                                            currentSongData =
                                                songState.songData;
                                          } else if (songState
                                              is PlayingState) {
                                            currentSongData =
                                                songState.songData;
                                          } else if (songState is PausedState) {
                                            currentSongData =
                                                songState.songData;
                                          }
                                          return BlocBuilder<FavoritesBloc,
                                              FavoritesState>(
                                            buildWhen: (previous, current) {
                                              // Rebuild when song changes or favorite state changes
                                              if (previous
                                                      is IsFavoritesState &&
                                                  current is IsFavoritesState) {
                                                return previous.vId !=
                                                        current.vId ||
                                                    previous.isFavorites !=
                                                        current.isFavorites;
                                              }
                                              return previous != current;
                                            },
                                            builder: (context, favState) {
                                              bool isFavorite = false;
                                              if (favState
                                                      is IsFavoritesState &&
                                                  favState.vId ==
                                                      currentSongData.vId) {
                                                isFavorite =
                                                    favState.isFavorites;
                                              }
                                              return IconButton(
                                                onPressed: () {
                                                  if (isFavorite) {
                                                    context
                                                        .read<FavoritesBloc>()
                                                        .add(RemoveFromFavoritesEvent(
                                                            vId: currentSongData
                                                                .vId));
                                                  } else {
                                                    context
                                                        .read<FavoritesBloc>()
                                                        .add(AddToFavoritesEvent(
                                                            song:
                                                                currentSongData));
                                                  }
                                                },
                                                icon: Icon(
                                                  isFavorite
                                                      ? CupertinoIcons
                                                          .heart_fill
                                                      : CupertinoIcons.heart,
                                                  color: isFavorite
                                                      ? Colors.red
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.6),
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

                                // Progress Bar
                                StreamBuilderWidget(screenSize: screenSize),
                                const SizedBox(height: 7),

                                // Controls (Prev, Play, Next)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.13),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        iconSize: 40,
                                        onPressed: () {
                                          context
                                              .read<SongstreamBloc>()
                                              .add(PlayPreviousSongEvent());
                                        },
                                        icon: const Icon(
                                            CupertinoIcons.backward_fill),
                                      ),
                                      BlocBuilder<SongstreamBloc,
                                          SongstreamState>(
                                        buildWhen: (previous, current) {
                                          String? prevId;
                                          String? currId;
                                          if (previous is LoadingState) prevId = previous.songData.vId;
                                          if (previous is PlayingState) prevId = previous.songData.vId;
                                          if (previous is PausedState) prevId = previous.songData.vId;
                                          if (current is LoadingState) currId = current.songData.vId;
                                          if (current is PlayingState) currId = current.songData.vId;
                                          if (current is PausedState) currId = current.songData.vId;
                                          return currId != null && currId != prevId;
                                        },
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
                                                isPlaylist: widget.routeData[
                                                        "isplaylist"] ??
                                                    false,
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
                                        icon: const Icon(
                                            CupertinoIcons.forward_fill),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Volume Slider
                                VolumeSlider(screenWidth: screenWidth),

                                const Spacer(flex: 2),

                                // Bottom Actions
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenSize * 0.024,
                                      left: screenWidth * 0.12,
                                      right: screenWidth * 0.12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BlocBuilder<SongstreamBloc,
                                          SongstreamState>(
                                        builder: (context, songStreamState) {
                                          Songmodel activeSong = songData;
                                          if (songStreamState is PlayingState) {
                                            activeSong =
                                                songStreamState.songData;
                                          } else if (songStreamState
                                              is PausedState) {
                                            activeSong =
                                                songStreamState.songData;
                                          } else if (songStreamState
                                              is LoadingState) {
                                            activeSong =
                                                songStreamState.songData;
                                          }
                                          return IconButton(
                                            onPressed: () {
                                              context.pop();
                                              final cached = context
                                                  .read<Repository>()
                                                  .getCachedArtist(
                                                      activeSong
                                                          .artist.artistId,
                                                      activeSong.artist.name);
                                              context.pushNamed(
                                                  RouterName.artistName,
                                                  extra: cached ??
                                                      ArtistModel(
                                                          artist:
                                                              activeSong.artist,
                                                          thumbnail: ""));
                                            },
                                            icon: Icon(
                                              CupertinoIcons
                                                  .person_crop_circle_fill,
                                              color: Colors.red
                                                  .withValues(alpha: 0.8),
                                              size: 28.5,
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: _openLyrics,
                                        icon: Icon(
                                          Icons.lyrics_outlined,
                                          color:
                                              Colors.red.withValues(alpha: 0.8),
                                          size: 28.5,
                                        ),
                                      ),
                                      BlocBuilder<SongstreamBloc,
                                          SongstreamState>(
                                        buildWhen: (previous, current) =>
                                            previous != current,
                                        builder: (context, state) {
                                          return IconButton(
                                            onPressed: () {
                                              context
                                                  .read<SongstreamBloc>()
                                                  .add(LoopEvent());
                                            },
                                            // icon: Icon(
                                            //   context
                                            //           .read<SongstreamBloc>()
                                            //           .getLoopStatus
                                            //       ? FontAwesomeIcons.repeat
                                            //       : FontAwesomeIcons.shuffle,
                                            //   color: Colors.red.withValues(alpha: 0.8),
                                            //   size: 23,
                                            // ),
                                            icon: FaIcon(
                                              context
                                                      .read<SongstreamBloc>()
                                                      .getLoopStatus
                                                  ? FontAwesomeIcons.repeat
                                                  : FontAwesomeIcons.shuffle,
                                              color: Colors.red
                                                  .withValues(alpha: 0.8),
                                              size: 23,
                                            ),
                                          );
                                        },
                                      ),
                                      // Download button with progress indicator
                                      //  Wrap the Menu/Download button in a Container with the GlobalKey
                                      Container(
                                        key: _menuButtonKey,
                                        child: BlocBuilder<SongstreamBloc,
                                            SongstreamState>(
                                          buildWhen: (previous, current) =>
                                              previous != current,
                                          builder: (context, songState) {
                                            // Get current song from state
                                            Songmodel currentSongData =
                                                songData;
                                            if (songState is LoadingState) {
                                              currentSongData =
                                                  songState.songData;
                                            } else if (songState
                                                is PlayingState) {
                                              currentSongData =
                                                  songState.songData;
                                            } else if (songState
                                                is PausedState) {
                                              currentSongData =
                                                  songState.songData;
                                            }
                                            return BlocBuilder<DownloadBloc,
                                                DownloadState>(
                                              builder: (context, state) {
                                                final isDownloading = state
                                                    is DownloadPercantageStatusState;

                                                if (isDownloading) {
                                                  return StreamBuilder<double>(
                                                    stream:
                                                        state.percentageStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      final progress =
                                                          snapshot.data ?? 0.0;
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            _showMoreOptions(
                                                                context,
                                                                currentSongData,
                                                                screenSize),
                                                        child: SizedBox(
                                                          width: 32,
                                                          height: 32,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              // Circular progress indicator
                                                              CircularProgressIndicator(
                                                                value:
                                                                    progress /
                                                                        100,
                                                                strokeWidth: 3,
                                                                backgroundColor: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                  Colors.red
                                                                      .withValues(
                                                                          alpha:
                                                                              0.6),
                                                                ),
                                                              ),
                                                              // Cloud download icon
                                                              Icon(
                                                                CupertinoIcons
                                                                    .cloud_download,
                                                                color: Colors
                                                                    .red
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6),
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
                                                    onPressed: () =>
                                                        _showMoreOptions(
                                                            context,
                                                            currentSongData,
                                                            screenSize),
                                                    // icon: Icon(
                                                    //   FontAwesomeIcons.list,
                                                    //   color: Colors.red
                                                    //       .withValues(alpha: 0.8),
                                                    //   size: 24,
                                                    // ),
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.list,
                                                      color: Colors.red
                                                          .withValues(
                                                              alpha: 0.8),
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
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _showUpcomingSongsBottomSheet(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 40.0),
                                      child: Container(
                                        width: 40,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //   child: Container(
                                //     width: 40,
                                //     height: 5,
                                //     margin: const EdgeInsets.only(bottom: 5),
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context)
                                //           .colorScheme
                                //           .onSurface
                                //           .withValues(alpha: 0.5),
                                //       borderRadius: BorderRadius.circular(10),
                                //     ),
                                //   ),
                                // ),
                                // ),
                              ],
                            ),
                          ),
                        ),

                      // Animated Lyrics Page (Slides in from bottom to top, out top to bottom)
                      AnimatedBuilder(
                        animation: _lyricsAnimController,
                        builder: (context, child) {
                          if (_lyricsAnimController.value == 0 &&
                              !_lyricsAnimController.isAnimating &&
                              !_isLyricsView.value) {
                            return const SizedBox.shrink();
                          }
                          return SlideTransition(
                            position: _lyricsSlideAnimation,
                            child: ClipRect(
                              child: child!,
                            ),
                          );
                        },
                        child: AppleMusicLyricsView(
                          songData: songData,
                          screenSize: screenSize,
                          screenWidth: screenWidth,
                          songIndex: songIndex,
                          route: route,
                          isPlaylist:
                              widget.routeData["isplaylist"] ?? false,
                          onCloseLyrics: _closeLyrics,
                          onOpenQueue: () =>
                              _showUpcomingSongsBottomSheet(context),
                          onShowOptions: (menuKey) => _showMoreOptions(
                            context,
                            songData,
                            screenSize,
                            buttonKey: menuKey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
    if (_isUpcomingSheetOpen) return;
    _isUpcomingSheetOpen = true;

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
                onTap:
                    () {}, // Prevent tap from closing when tapping on the sheet
                child: const UpcomingSongsBottomSheet(),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isUpcomingSheetOpen = false;
    });
  }
}
