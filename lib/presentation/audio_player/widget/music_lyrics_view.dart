import 'dart:async';
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
  final ValueNotifier<bool>? isLyricsVisible;

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
    this.isLyricsVisible,
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
  bool _initialScrollDone = false;
  Timer? _userScrollTimer;
  StreamSubscription<Duration>? _seekSubscription;
  Duration _syncOffset = Duration.zero;
  late Songmodel _currentSong;

  static int? _parseDurationString(String? durationStr) {
    if (durationStr == null || durationStr.trim().isEmpty) return null;
    final parts = durationStr.trim().split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final s = int.tryParse(parts[1]);
      if (m != null && s != null) return m * 60 + s;
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final s = int.tryParse(parts[2]);
      if (h != null && m != null && s != null) return h * 3600 + m * 60 + s;
    }
    return null;
  }

  void _onVisibilityChanged() {
    if (widget.isLyricsVisible?.value == true) {
      _userScrollTimer?.cancel();
      _userIsScrolling = false;
      _initialScrollDone = false;
      _lastActiveIndex = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final lyricsState = context.read<LyricsBloc>().state;
        if (lyricsState is LyricsLoadedState &&
            lyricsState.lyricModel.hasSyncedLyrics) {
          final currentPos = context.read<SongstreamBloc>().currentPosition;
          final activeIndex = LyricModel.findActiveLineIndex(
            lyricsState.lyricModel.syncedLyrics,
            currentPos,
            offset: _syncOffset,
          );
          if (activeIndex >= 0) {
            _lastActiveIndex = activeIndex;
            _scrollToActiveLine(activeIndex, instant: true);
            _initialScrollDone = true;
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.isLyricsVisible?.addListener(_onVisibilityChanged);
    final songstreamBloc = context.read<SongstreamBloc>();
    final songState = songstreamBloc.state;
    if (songState is LoadingState) {
      _currentSong = songState.songData;
    } else if (songState is PlayingState) {
      _currentSong = songState.songData;
    } else if (songState is PausedState) {
      _currentSong = songState.songData;
    } else {
      _currentSong = widget.songData;
    }

    final streamSec = songstreamBloc.songDuration.inSeconds;
    final durationSec =
        streamSec > 0 ? streamSec : _parseDurationString(_currentSong.duration);
    context.read<LyricsBloc>().add(
          LoadLyricsEvent(
            songData: _currentSong,
            durationSeconds: durationSec,
          ),
        );

    final lyricsBloc = context.read<LyricsBloc>();
    // Listen to duration bar seek events to instantly synchronize lyrics on seek
    _seekSubscription =
        songstreamBloc.seekPositionStream.listen((seekPosition) {
      if (!mounted) return;
      _userScrollTimer?.cancel();
      _userIsScrolling = false;
      final lyricsState = lyricsBloc.state;
      if (lyricsState is LyricsLoadedState &&
          lyricsState.lyricModel.hasSyncedLyrics) {
        final activeIndex = LyricModel.findActiveLineIndex(
          lyricsState.lyricModel.syncedLyrics,
          seekPosition,
          offset: _syncOffset,
        );
        _lastActiveIndex = activeIndex;
        if (activeIndex >= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToActiveLine(activeIndex, instant: false);
          });
        }
      }
    });

    // Auto-scroll immediately to currently playing line on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lyricsState = context.read<LyricsBloc>().state;
      if (lyricsState is LyricsLoadedState &&
          lyricsState.lyricModel.hasSyncedLyrics) {
        final currentPos = context.read<SongstreamBloc>().currentPosition;
        final activeIndex = LyricModel.findActiveLineIndex(
          lyricsState.lyricModel.syncedLyrics,
          currentPos,
          offset: _syncOffset,
        );
        if (activeIndex >= 0) {
          _lastActiveIndex = activeIndex;
          _scrollToActiveLine(activeIndex, instant: true);
          _initialScrollDone = true;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppleMusicLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLyricsVisible != widget.isLyricsVisible) {
      oldWidget.isLyricsVisible?.removeListener(_onVisibilityChanged);
      widget.isLyricsVisible?.addListener(_onVisibilityChanged);
    }
    final songState = context.read<SongstreamBloc>().state;
    Songmodel activeSong = widget.songData;
    if (songState is LoadingState) {
      activeSong = songState.songData;
    } else if (songState is PlayingState) {
      activeSong = songState.songData;
    } else if (songState is PausedState) {
      activeSong = songState.songData;
    }

    if (activeSong.vId != _currentSong.vId) {
      setState(() {
        _currentSong = activeSong;
        _lastActiveIndex = -1;
        _initialScrollDone = false;
        _syncOffset = Duration.zero;
        _lineKeys.clear();
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      final streamSec = context.read<SongstreamBloc>().songDuration.inSeconds;
      final durationSec =
          streamSec > 0 ? streamSec : _parseDurationString(activeSong.duration);
      context.read<LyricsBloc>().add(
            LoadLyricsEvent(
              songData: activeSong,
              durationSeconds: durationSec,
            ),
          );
    }
  }

  @override
  void dispose() {
    widget.isLyricsVisible?.removeListener(_onVisibilityChanged);
    _seekSubscription?.cancel();
    _userScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine(int index, {bool instant = false}) {
    if (_userIsScrolling) return;
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToActiveLine(index, instant: instant);
      });
      return;
    }
    final key = _lineKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.35,
        duration: instant ? Duration.zero : const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToActiveLine(index, instant: instant);
      });
    }
  }

  // Dialog allowing users to fine-tune lyrics sync offset (e.g. ±0.5s)
  void _showSyncOffsetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final theme = Theme.of(dialogCtx);
            final isDark = theme.brightness == Brightness.dark;
            final offsetSeconds = _syncOffset.inMilliseconds / 1000.0;
            final offsetStr = offsetSeconds == 0.0
                ? '0.0s'
                : '${offsetSeconds > 0 ? "+" : ""}${offsetSeconds.toStringAsFixed(1)}s';

            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.88)
                      : theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lyrics Timing Sync',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Adjust timing if lyrics appear too early or too late',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        offsetStr,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () {
                              setState(() {
                                _syncOffset -=
                                    const Duration(milliseconds: 500);
                              });
                              setDialogState(() {});
                            },
                            icon: const Icon(CupertinoIcons.minus),
                            tooltip: '-0.5s',
                          ),
                          const SizedBox(width: 20),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _syncOffset = Duration.zero;
                              });
                              setDialogState(() {});
                            },
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 20),
                          IconButton.filledTonal(
                            onPressed: () {
                              setState(() {
                                _syncOffset +=
                                    const Duration(milliseconds: 500);
                              });
                              setDialogState(() {});
                            },
                            icon: const Icon(CupertinoIcons.plus),
                            tooltip: '+0.5s',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
            _initialScrollDone = false;
            _syncOffset = Duration.zero;
            _lineKeys.clear();
          });
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
          final streamSec =
              context.read<SongstreamBloc>().songDuration.inSeconds;
          final durationSec = streamSec > 0
              ? streamSec
              : _parseDurationString(newSong.duration);
          context.read<LyricsBloc>().add(
                LoadLyricsEvent(
                  songData: newSong,
                  durationSeconds: durationSec,
                ),
              );
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
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 150) {
            widget.onCloseLyrics();
          }
        },
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

  // Top Header (Mini Art + Song Title + Artist + Timing Sync Button)
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

          const SizedBox(width: 8),

          // Timing Sync Offset Pill / Button
          BlocBuilder<LyricsBloc, LyricsState>(
            builder: (context, state) {
              if (state is LyricsLoadedState &&
                  state.lyricModel.hasSyncedLyrics) {
                final offsetSeconds = _syncOffset.inMilliseconds / 1000.0;
                final hasOffset = _syncOffset != Duration.zero;

                return GestureDetector(
                  onTap: () => _showSyncOffsetDialog(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasOffset
                          ? Colors.red.withValues(alpha: 0.2)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasOffset
                            ? Colors.red.withValues(alpha: 0.5)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.timer,
                          size: 13,
                          color: hasOffset
                              ? Colors.red
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasOffset
                              ? '${offsetSeconds > 0 ? "+" : ""}${offsetSeconds.toStringAsFixed(1)}s'
                              : 'Sync',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasOffset
                                ? Colors.red
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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

          if (!_initialScrollDone && isSynced) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final currentPos = context.read<SongstreamBloc>().currentPosition;
              final idx = LyricModel.findActiveLineIndex(
                state.lyricModel.syncedLyrics,
                currentPos,
                offset: _syncOffset,
              );
              if (idx >= 0) {
                _lastActiveIndex = idx;
                _scrollToActiveLine(idx, instant: true);
                _initialScrollDone = true;
              }
            });
          }

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
                  _userScrollTimer?.cancel();
                  _userIsScrolling = true;
                } else if (notification is ScrollEndNotification) {
                  _userScrollTimer?.cancel();
                  _userScrollTimer = Timer(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _userIsScrolling = false;
                      });
                      if (_lastActiveIndex >= 0) {
                        _scrollToActiveLine(_lastActiveIndex);
                      }
                    }
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

  // Synced Lyrics List - Fully rendered with SingleChildScrollView so ensureVisible works 100% reliably
  Widget _buildSyncedLyricsList(List<LyricLine> lines, bool isDark) {
    final streamBloc = context.read<SongstreamBloc>();

    return StreamBuilder<Duration>(
      initialData: streamBloc.currentPosition,
      stream: streamBloc.songPosition,
      builder: (context, snapshot) {
        final currentPosition = snapshot.data ?? Duration.zero;

        // Find active line index using fast binary search with user offset applied
        final activeIndex = LyricModel.findActiveLineIndex(
          lines,
          currentPosition,
          offset: _syncOffset,
        );

        // Trigger auto-scroll on line change or intro
        if (activeIndex != _lastActiveIndex) {
          _lastActiveIndex = activeIndex;
          if (activeIndex >= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToActiveLine(activeIndex, instant: !_initialScrollDone);
              _initialScrollDone = true;
            });
          } else if (lines.isNotEmpty &&
              (currentPosition + _syncOffset) < lines.first.timestamp) {
            // Intro before first line: ensure scroll is at top
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients &&
                  _scrollController.offset > 0 &&
                  !_userIsScrolling) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          }
        }

        final onSurface = Theme.of(context).colorScheme.onSurface;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(lines.length, (index) {
              final line = lines[index];
              final isActive = index == activeIndex;
              final isPast = activeIndex >= 0
                  ? index < activeIndex
                  : (line.endTime ?? line.timestamp) <=
                      (currentPosition + _syncOffset);

              _lineKeys[index] ??= GlobalKey();

              return GestureDetector(
                key: _lineKeys[index],
                onTap: () {
                  _userScrollTimer?.cancel();
                  _userIsScrolling = false;
                  context.read<SongstreamBloc>().add(
                        SeekToEvent(position: line.timestamp),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: line.text == '♪'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.music_note,
                              size: isActive ? 24 : 18,
                              color: isActive
                                  ? (isDark ? Colors.white : onSurface)
                                  : (isDark
                                      ? Colors.white.withValues(
                                          alpha: isPast ? 0.35 : 0.45,
                                        )
                                      : onSurface.withValues(
                                          alpha: isPast ? 0.35 : 0.45,
                                        )),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instrumental',
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
                                fontSize: isActive ? 22 : 17,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          line.text,
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
                            fontWeight:
                                isActive ? FontWeight.w800 : FontWeight.w600,
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
            }),
          ),
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
              CupertinoIcons.arrow_left_circle_fill,
              color: Colors.red.withValues(alpha: 0.8),
              size: 28.5,
            ),
          ),

          // Sync On / Off (disabled state if lyric has no sync; long press opens timing sync dialog)
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
                onLongPress: hasSync ? () => _showSyncOffsetDialog(context) : null,
                icon: Icon(
                  hasSync
                      ? (isSyncOn
                          ? Icons.spatial_audio_off
                          : Icons.spatial_audio_off_outlined)
                      : Icons.spatial_audio_off_outlined,
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

          // Shuffle and Sequence combined in one (exact copy of audio player)
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

          // Menu (Three lines, exact copy of audio player)
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

  // Bottom Grab Pill (opens Up Next bottom sheet)
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
