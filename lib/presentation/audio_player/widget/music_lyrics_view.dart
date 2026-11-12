import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/lyrics_source.dart';
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

class MusicLyricsView extends StatefulWidget {
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

  const MusicLyricsView({
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
  State<MusicLyricsView> createState() => _MusicLyricsViewState();
}

class _MusicLyricsViewState extends State<MusicLyricsView> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;
  bool _userIsScrolling = false;
  bool _initialScrollDone = false;
  Timer? _userScrollTimer;
  StreamSubscription<Duration>? _seekSubscription;
  Duration _syncOffset = Duration.zero;
  late Songmodel _currentSong;
  final ValueNotifier<bool> _isLocked = ValueNotifier(false);

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
      final lyricsState = context.read<LyricsBloc>().state;
      if (lyricsState is LyricsLoadedState) {
        _syncOffset = lyricsState.syncOffset;
      }
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

    final initialLyricsState = context.read<LyricsBloc>().state;
    if (initialLyricsState is LyricsLoadedState &&
        initialLyricsState.songData.vId == _currentSong.vId) {
      _syncOffset = initialLyricsState.syncOffset;
    } else {
      _syncOffset = HiveDataBaseSingleton.instance
          .getLyricSyncOffset(_currentSong.vId, LyricsSource.ytMusic.name);
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
  void didUpdateWidget(covariant MusicLyricsView oldWidget) {
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
        _syncOffset = HiveDataBaseSingleton.instance
            .getLyricSyncOffset(activeSong.vId, LyricsSource.ytMusic.name);
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
    _isLocked.dispose();
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

  // bottom sheet for fine-tuning lyrics sync
  void _showSyncOffsetDialog(BuildContext context) {
    final lyricsBloc = context.read<LyricsBloc>();
    final lyricsState = lyricsBloc.state;
    final initialOffset =
        lyricsState is LyricsLoadedState ? lyricsState.syncOffset : _syncOffset;
    final activeSource = lyricsState is LyricsLoadedState
        ? lyricsState.source
        : LyricsSource.ytMusic;
    bool donePressed = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) {
        return _LyricsSyncTimerSheet(
          initialOffset: initialOffset,
          onOffsetChanged: (newOffset) {
            // Live update local state so lyrics scroll in real time.
            setState(() {
              _syncOffset = newOffset;
            });
          },
          onDone: (finalOffset) {
            donePressed = true;
            // Dispatch persistent save to bloc.
            lyricsBloc.add(UpdateLyricSyncOffsetEvent(
              songId: _currentSong.vId,
              source: activeSource,
              offset: finalOffset,
            ));
          },
        );
      },
    ).then((_) {
      // If user dismissed sheet without tapping Done, revert live preview to saved offset
      if (!donePressed && mounted) {
        setState(() {
          _syncOffset = initialOffset;
        });
      }
    });
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
            _syncOffset = HiveDataBaseSingleton.instance
                .getLyricSyncOffset(newSong.vId, LyricsSource.ytMusic.name);
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
      child: BlocListener<LyricsBloc, LyricsState>(
        // Sync _syncOffset from bloc state whenever offset changes
        // (handles restore after pop/reopen, provider switch, and cross-device cloud load).
        listenWhen: (prev, curr) {
          if (curr is! LyricsLoadedState) return false;
          if (prev is! LyricsLoadedState) return true;
          return curr.syncOffset != prev.syncOffset;
        },
        listener: (context, state) {
          if (state is LyricsLoadedState && mounted) {
            setState(() {
              _syncOffset = state.syncOffset;
            });
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
                          : theme.scaffoldBackgroundColor
                              .withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content inside SafeArea
            SafeArea(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isLocked,
                builder: (context, isLocked, _) {
                  return Stack(
                    children: [
                      // AbsorbPointer blocks all touches when locked, except the
                      // lock button which lives outside this layer
                      AbsorbPointer(
                        absorbing: isLocked,
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
                                  StreamBuilderWidget(
                                      screenSize: widget.screenSize),
                                  const SizedBox(height: 7),

                                  // Controls (Prev, Play/Pause, Next)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: widget.screenWidth * 0.13),
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
                                          icon: const Icon(
                                              CupertinoIcons.forward_fill),
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

                      // Lock button overlay  always on top 
                      Positioned(
                        top: 30,
                        right: 16,
                        child: _buildLockButton(isLocked),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lock Button — tappable even when screen is locked
  Widget _buildLockButton(bool isLocked) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _isLocked.value = !_isLocked.value;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.red.withValues(alpha: 0.18)
              : onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
                ? Colors.red.withValues(alpha: 0.45)
                : onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Icon(
          isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open,
          size: 18,
          color: isLocked ? Colors.red : onSurface.withValues(alpha: 0.55),
        ),
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
                // Divider(),
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

  // Synced Lyrics List - Fully rendered with SingleChildScrollView
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
                onLongPress:
                    hasSync ? () => _showSyncOffsetDialog(context) : null,
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

          // Lyrics Source Picker
          BlocBuilder<LyricsBloc, LyricsState>(
            builder: (context, lyricsState) {
              final isLoaded = lyricsState is LyricsLoadedState;
              return GestureDetector(
                onTap: () => _showLyricsSourceSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: isLoaded ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: isLoaded ? 0.2 : 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lyrics_outlined,
                        size: 14,
                        color:
                            Colors.red.withValues(alpha: isLoaded ? 0.85 : 0.4),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isLoaded
                            ? (lyricsState.source == LyricsSource.ytMusic
                                ? 'NEX'
                                : 'LRC')
                            : 'SRC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red
                              .withValues(alpha: isLoaded ? 0.85 : 0.4),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // bottom sheet for switching lyrics source + sync timer
  void _showLyricsSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<LyricsBloc>(),
          child: _LyricsSourceSheet(
            onSyncTap: () {
              context.pop(sheetCtx);
              _showSyncOffsetDialog(context);
            },
          ),
        );
      },
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

// Lyrics Source Bottom Sheet

class _LyricsSourceSheet extends StatelessWidget {
  final VoidCallback onSyncTap;

  const _LyricsSourceSheet({
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          color: isDark
              ? Colors.black.withValues(alpha: 0.85)
              : theme.scaffoldBackgroundColor.withValues(alpha: 0.93),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lyrics Setting',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Switch between providers or adjust sync',
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                BlocBuilder<LyricsBloc, LyricsState>(
                  builder: (context, state) {
                    final isLoaded = state is LyricsLoadedState;
                    final activeSource =
                        isLoaded ? state.source : LyricsSource.ytMusic;
                    final hasYt = isLoaded && state.hasYtLyrics;
                    final hasLrc = isLoaded && state.hasLrclibLyrics;
                    final hasSynced =
                        isLoaded && state.lyricModel.hasSyncedLyrics;
                    // Read active sync offset directly from bloc state.
                    final currentSyncOffset =
                        isLoaded ? state.syncOffset : Duration.zero;

                    return Column(
                      children: [
                        //  YT Music Option
                        _SourceTile(
                          label: 'Nex Music',
                          subtitle: hasYt
                              ? (state.ytLyrics!.hasSyncedLyrics
                                  ? 'Synced lyrics'
                                  : 'Plain lyrics')
                              : 'Not available for this song',
                          icon: CupertinoIcons.play_circle_fill,
                          isActive: activeSource == LyricsSource.ytMusic,
                          isAvailable: hasYt,
                          onTap: hasYt
                              ? () {
                                  context.read<LyricsBloc>().add(
                                        const SwitchLyricsSourceEvent(
                                            LyricsSource.ytMusic),
                                      );
                                  context.pop(context);
                                }
                              : null,
                        ),
                        const SizedBox(height: 10),
                        //  LRCLIB Option
                        _SourceTile(
                          label: 'LRCLIB',
                          subtitle: hasLrc
                              ? (state.lrclibLyrics!.hasSyncedLyrics
                                  ? 'Synced lyrics'
                                  : 'Plain lyrics')
                              : 'Not available for this song',
                          icon: CupertinoIcons.doc_text_fill,
                          isActive: activeSource == LyricsSource.lrclib,
                          isAvailable: hasLrc,
                          onTap: hasLrc
                              ? () {
                                  context.read<LyricsBloc>().add(
                                        const SwitchLyricsSourceEvent(
                                            LyricsSource.lrclib),
                                      );
                                  context.pop(context);
                                }
                              : null,
                        ),

                        //  Sync Timer
                        if (hasSynced) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, thickness: 0.4)
                        ],
                        if (hasSynced)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: currentSyncOffset != Duration.zero
                                    ? Colors.red.withValues(alpha: 0.18)
                                    : onSurface.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CupertinoIcons.timer,
                                size: 20,
                                color: currentSyncOffset != Duration.zero
                                    ? Colors.red
                                    : onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            title: Text(
                              'Sync Timer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            subtitle: Text(
                              currentSyncOffset == Duration.zero
                                  ? 'Adjust timing if lyrics are early or late'
                                  : 'Offset: ${currentSyncOffset.inMilliseconds > 0 ? '+' : ''}${(currentSyncOffset.inMilliseconds / 1000.0).toStringAsFixed(1)}s',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentSyncOffset != Duration.zero
                                    ? Colors.red.withValues(alpha: 0.85)
                                    : onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            trailing: Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: onSurface.withValues(alpha: 0.3),
                            ),
                            onTap: onSyncTap,
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _SourceTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.red.withValues(alpha: isDark ? 0.18 : 0.1)
              : onSurface.withValues(alpha: isAvailable ? 0.06 : 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.red.withValues(alpha: 0.5)
                : onSurface.withValues(alpha: isAvailable ? 0.12 : 0.06),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Source icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.red.withValues(alpha: 0.2)
                    : onSurface.withValues(alpha: isAvailable ? 0.08 : 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? Colors.red
                    : onSurface.withValues(alpha: isAvailable ? 0.65 : 0.3),
              ),
            ),
            const SizedBox(width: 14),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.red
                          : onSurface.withValues(
                              alpha: isAvailable ? 1.0 : 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? Colors.red.withValues(alpha: 0.75)
                          : onSurface.withValues(
                              alpha: isAvailable ? 0.5 : 0.3),
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark if active
            if (isActive)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 20,
                color: Colors.red,
              )
            else if (!isAvailable)
              Icon(
                CupertinoIcons.xmark_circle,
                size: 18,
                color: onSurface.withValues(alpha: 0.25),
              ),
          ],
        ),
      ),
    );
  }
}

//  Lyrics Timing Sync Bottom Sheet

class _LyricsSyncTimerSheet extends StatefulWidget {
  final Duration initialOffset;
  final ValueChanged<Duration> onOffsetChanged;
  final ValueChanged<Duration> onDone;

  const _LyricsSyncTimerSheet({
    required this.initialOffset,
    required this.onOffsetChanged,
    required this.onDone,
  });

  @override
  State<_LyricsSyncTimerSheet> createState() => _LyricsSyncTimerSheetState();
}

class _LyricsSyncTimerSheetState extends State<_LyricsSyncTimerSheet> {
  late Duration _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  void _adjustOffset(Duration delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final newMillis = _offset.inMilliseconds + delta.inMilliseconds;
      // Clamp between -10.0s and +10.0s
      final clampedMillis = newMillis.clamp(-10000, 10000);
      _offset = Duration(milliseconds: clampedMillis);
    });
    widget.onOffsetChanged(_offset);
  }

  void _resetOffset() {
    if (_offset == Duration.zero) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _offset = Duration.zero;
    });
    widget.onOffsetChanged(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final offsetSec = _offset.inMilliseconds / 1000.0;
    final isZero = _offset == Duration.zero;
    final offsetStr = isZero
        ? '0.0s'
        : '${offsetSec > 0 ? "+" : ""}${offsetSec.toStringAsFixed(1)}s';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          color: isDark
              ? Colors.black.withValues(alpha: 0.88)
              : theme.scaffoldBackgroundColor.withValues(alpha: 0.94),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Timer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fine-tune lyrics to match vocals',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(32, 32),
                      color: isZero
                          ? onSurface.withValues(alpha: 0.04)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      onPressed: isZero ? null : _resetOffset,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_counterclockwise,
                            size: 13,
                            color: isZero
                                ? onSurface.withValues(alpha: 0.25)
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isZero
                                  ? onSurface.withValues(alpha: 0.25)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1E).withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isZero
                          ? onSurface.withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.35),
                      width: isZero ? 1 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        offsetStr,
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: isZero ? onSurface : Colors.red,
                          letterSpacing: -1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isZero
                              ? onSurface.withValues(alpha: 0.08)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isZero
                                  ? CupertinoIcons.checkmark_alt
                                  : (_offset > Duration.zero
                                      ? CupertinoIcons.forward_fill
                                      : CupertinoIcons.backward_fill),
                              size: 12,
                              color: isZero
                                  ? onSurface.withValues(alpha: 0.65)
                                  : Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isZero
                                  ? 'In Sync (Default)'
                                  : (_offset > Duration.zero
                                      ? 'Lyrics advanced by ${offsetSec.abs().toStringAsFixed(1)}s (earlier)'
                                      : 'Lyrics delayed by ${offsetSec.abs().toStringAsFixed(1)}s (later)'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isZero
                                    ? onSurface.withValues(alpha: 0.65)
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StepButton(
                        icon: CupertinoIcons.minus,
                        label: '0.5s',
                        subtitle: 'Delay lyrics',
                        onTap: () =>
                            _adjustOffset(const Duration(milliseconds: -500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StepButton(
                        icon: CupertinoIcons.plus,
                        label: '0.5s',
                        subtitle: 'Advance lyrics',
                        onTap: () =>
                            _adjustOffset(const Duration(milliseconds: 500)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FineTuneButton(
                        icon: CupertinoIcons.minus,
                        label: '0.1s Fine',
                        onTap: () =>
                            _adjustOffset(const Duration(milliseconds: -100)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FineTuneButton(
                        icon: CupertinoIcons.plus,
                        label: '0.1s Fine',
                        onTap: () =>
                            _adjustOffset(const Duration(milliseconds: 100)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tap − if lyrics appear ahead of vocals · Tap + if lyrics appear late',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: onSurface.withValues(alpha: 0.45),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      widget.onDone(_offset);
                      context.pop();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FineTuneButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FineTuneButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: isDark ? 0.05 : 0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: onSurface.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
