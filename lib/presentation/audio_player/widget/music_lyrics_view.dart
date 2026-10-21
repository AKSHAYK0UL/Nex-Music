import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nex_music/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';
import 'package:nex_music/presentation/audio_player/widget/volume_slider.dart';

// Swipe detector to handle upward swipes to open the bottom sheet
class _LyricsSwipeUpDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeUp;

  const _LyricsSwipeUpDetector({
    required this.child,
    required this.onSwipeUp,
  });

  @override
  State<_LyricsSwipeUpDetector> createState() => _LyricsSwipeUpDetectorState();
}

class _LyricsSwipeUpDetectorState extends State<_LyricsSwipeUpDetector> {
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

class AppleMusicLyricsView extends StatefulWidget {
  final Songmodel songData;
  final double screenSize;
  final double screenWidth;
  final int songIndex;
  final SongMiniPlayerRoute route;
  final bool isPlaylist;
  final VoidCallback onCloseLyrics;
  final VoidCallback onOpenQueue;
  final void Function(GlobalKey menuKey) onShowOptions;

  const AppleMusicLyricsView({
    super.key,
    required this.songData,
    required this.screenSize,
    required this.screenWidth,
    required this.songIndex,
    required this.route,
    required this.isPlaylist,
    required this.onCloseLyrics,
    required this.onOpenQueue,
    required this.onShowOptions,
  });

  @override
  State<AppleMusicLyricsView> createState() => _AppleMusicLyricsViewState();
}

class _AppleMusicLyricsViewState extends State<AppleMusicLyricsView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _lyricsMenuButtonKey = GlobalKey();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;
  bool _userIsScrolling = false;
  late Songmodel _currentSong;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.songData;
    context.read<LyricsBloc>().add(
          LoadLyricsEvent(songData: _currentSong),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine(int index) {
    if (_userIsScrolling) return;
    final key = _lineKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.35,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final quality = HiveDataBaseSingleton.instance.getData.thumbnailQuality;
    final highResUrl = _currentSong.isLocal
        ? _currentSong.thumbnail
        : getHighResThumbnail(
            _currentSong.thumbnail,
            videoId: _currentSong.vId,
            quality: quality,
          );

    return BlocListener<SongstreamBloc, SongstreamState>(
      // Only listen when the song ID actually changes so button taps never rebuild the tree
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
        Songmodel? newSong;
        if (state is LoadingState) newSong = state.songData;
        if (state is PlayingState) newSong = state.songData;
        if (state is PausedState) newSong = state.songData;
        if (newSong != null && newSong.vId != _currentSong.vId) {
          setState(() {
            _currentSong = newSong!;
            _lastActiveIndex = -1;
            _lineKeys.clear();
          });
          context.read<LyricsBloc>().add(LoadLyricsEvent(songData: newSong));
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                cacheImage(
                  imageUrl: highResUrl,
                  fallbackUrl: _currentSong.thumbnail,
                  width: double.infinity,
                  height: double.infinity,
                  islocal: _currentSong.isLocal,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.75)
                        : theme.scaffoldBackgroundColor.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),

          // Main Content inside SafeArea
          SafeArea(
            child: Column(
              children: [
                _buildTopGrabHandle(),

                _buildTopHeader(context, _currentSong, highResUrl),

                // Lyrics Area with Blur / Fade ShaderMask on top and bottom lines
                // (Completely isolated: scrolling here NEVER opens the bottom modal sheet)
                Expanded(
                  child: _buildLyricsArea(context, isDark),
                ),

                // Bottom controls area with swipe-up detector to open queue
                _LyricsSwipeUpDetector(
                  onSwipeUp: widget.onOpenQueue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilderWidget(screenSize: widget.screenSize),
                      const SizedBox(height: 7),

                      // Controls (Prev, Play/Pause, Next)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.13),
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
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Player(
                                  songData: _currentSong,
                                  songIndex: widget.songIndex,
                                  screenSize: widget.screenSize,
                                  route: widget.route,
                                  isPlaylist: widget.isPlaylist,
                                ),
                              ),
                            ),
                            IconButton(
                              iconSize: 40,
                              onPressed: () {
                                context
                                    .read<SongstreamBloc>()
                                    .add(PlayNextSongEvent());
                              },
                              icon: const Icon(CupertinoIcons.forward_fill),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Volume Slider
                      VolumeSlider(screenWidth: widget.screenWidth),

                      const SizedBox(height: 16),

                      // Bottom Action Buttons matching audio player styling & layout
                      _buildBottomActionButtons(context),

                      // Bottom grab pill (tap opens up next bottom sheet)
                      _buildBottomGrabPill(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top Grab Handle
  Widget _buildTopGrabHandle() {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onCloseLyrics,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // Top Header (Mini Art + Song Title + Artist)
  Widget _buildTopHeader(
      BuildContext context, Songmodel currentSong, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          // Mini Album Art
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cacheImage(
                imageUrl: imageUrl,
                fallbackUrl: currentSong.thumbnail,
                width: 46,
                height: 46,
                islocal: currentSong.isLocal,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentSong.songName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentSong.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lyrics Display Area with Blur / Fade ShaderMask on top and bottom lines
  Widget _buildLyricsArea(BuildContext context, bool isDark) {
    return BlocBuilder<LyricsBloc, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoadingState) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 14),
                Text(
                  'Loading lyrics...',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is LyricsNotFoundState || state is LyricsErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.music_mic,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lyrics Unavailable',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We couldn\'t find lyrics for this song.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is LyricsLoadedState) {
          final isSynced =
              state.isSyncEnabled && state.lyricModel.hasSyncedLyrics;

          final lyricsWidget = isSynced
              ? _buildSyncedLyricsList(state.lyricModel.syncedLyrics, isDark)
              : _buildPlainLyricsList(
                  state.lyricModel.plainLyrics ?? '', isDark);

          // Apply blur/fade gradient shader mask on top and bottom lines
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.12, 0.88, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _userIsScrolling = true;
                } else if (notification is ScrollEndNotification) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _userIsScrolling = false;
                  });
                }
                return false;
              },
              child: lyricsWidget,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Synced Lyrics List
  Widget _buildSyncedLyricsList(List<LyricLine> lines, bool isDark) {
    return StreamBuilder<Duration>(
      stream: context.read<SongstreamBloc>().songPosition,
      builder: (context, snapshot) {
        final currentPosition = snapshot.data ?? Duration.zero;

        // Find active line index
        int activeIndex = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].timestamp <= currentPosition) {
            activeIndex = i;
          } else {
            break;
          }
        }

        // Trigger auto-scroll on line change
        if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
          _lastActiveIndex = activeIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToActiveLine(activeIndex);
          });
        }

        final onSurface = Theme.of(context).colorScheme.onSurface;

        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final line = lines[index];
            final isActive = index == activeIndex;
            final isPast = index < activeIndex;

            _lineKeys[index] ??= GlobalKey();

            return GestureDetector(
              key: _lineKeys[index],
              onTap: () {
                context.read<SongstreamBloc>().add(
                      SeekToEvent(position: line.timestamp),
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  line.text.isEmpty ? '♪' : line.text,
                  style: TextStyle(
                    color: isActive
                        ? (isDark ? Colors.white : onSurface)
                        : (isDark
                            ? Colors.white.withValues(
                                alpha: isPast ? 0.35 : 0.45,
                              )
                            : onSurface.withValues(
                                alpha: isPast ? 0.35 : 0.45,
                              )),
                    fontSize: isActive ? 28 : 22,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.3,
                    shadows: isActive
                        ? [
                            Shadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.red.withValues(alpha: 0.25),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Plain Lyrics List
  Widget _buildPlainLyricsList(String plainLyrics, bool isDark) {
    final lines = plainLyrics.split('\n');
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final text = lines[index].trim();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            text.isEmpty ? ' ' : text,
            style: TextStyle(
              color: isDark ? Colors.white : onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }

  // Bottom Action Buttons (Player, Sync, Shuffle/Loop in one, Menu)
  Widget _buildBottomActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.screenSize * 0.024,
        left: widget.screenWidth * 0.12,
        right: widget.screenWidth * 0.12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Icon (tap pops back to audio player)
          IconButton(
            onPressed: widget.onCloseLyrics,
            icon: Icon(
              CupertinoIcons.play_circle_fill,
              color: Colors.red.withValues(alpha: 0.8),
              size: 28.5,
            ),
          ),

          // Sync On / Off (disabled state if lyric has no sync)
          BlocBuilder<LyricsBloc, LyricsState>(
            builder: (context, lyricsState) {
              final hasSync = lyricsState is LyricsLoadedState &&
                  lyricsState.lyricModel.hasSyncedLyrics;
              final isSyncOn =
                  lyricsState is LyricsLoadedState && lyricsState.isSyncEnabled;

              return IconButton(
                onPressed: () {
                  if (hasSync) {
                    context.read<LyricsBloc>().add(ToggleSyncLyricsEvent());
                    showSnackbar(
                      context,
                      isSyncOn ? 'Lyrics sync off' : 'Lyrics sync on',
                    );
                  } else {
                    showSnackbar(context, 'Synced lyrics not available');
                  }
                },
                icon: Icon(
                  hasSync
                      ? (isSyncOn
                          ? Icons.spatial_audio_off
                          : Icons.spatial_audio_off_outlined)
                      : CupertinoIcons.quote_bubble,
                  color: hasSync
                      ? (isSyncOn
                          ? Colors.red.withValues(alpha: 0.8)
                          : Colors.red.withValues(alpha: 0.55))
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.25),
                  size: 28.5,
                ),
              );
            },
          ),

          //  Shuffle and Sequence combined in one (exact copy of audio player)
          BlocBuilder<SongstreamBloc, SongstreamState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  context.read<SongstreamBloc>().add(LoopEvent());
                },
                icon: FaIcon(
                  context.read<SongstreamBloc>().getLoopStatus
                      ? FontAwesomeIcons.repeat
                      : FontAwesomeIcons.shuffle,
                  color: Colors.red.withValues(alpha: 0.8),
                  size: 23,
                ),
              );
            },
          ),

          //  Menu (Three lines, exact copy of audio player)
          Container(
            key: _lyricsMenuButtonKey,
            child: IconButton(
              onPressed: () => widget.onShowOptions(_lyricsMenuButtonKey),
              icon: FaIcon(
                FontAwesomeIcons.list,
                color: Colors.red.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  Bottom Grab Pill (opens Up Next bottom sheet)
  Widget _buildBottomGrabPill(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpenQueue,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
