import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';

class Player extends StatefulWidget {
  final Songmodel songData;
  final double screenSize;
  final int songIndex;
  final SongMiniPlayerRoute route;
  final bool isPlaylist;

  const Player({
    super.key,
    required this.songData,
    required this.screenSize,
    required this.route,
    required this.songIndex,
    required this.isPlaylist,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  // Tracks whether we are in a loading/buffering state.
  // BlocListener so it is ALWAYS up-to-date regardless of buildWhen.
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  // Tracks whether the current playback is paused (vs playing).
  final ValueNotifier<bool> _isPaused = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Sync with the current bloc state immediately on mount.
    _syncWithState(context.read<SongstreamBloc>().state);
  }

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWithState(context.read<SongstreamBloc>().state);
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _isPaused.dispose();
    super.dispose();
  }

  void _syncWithState(SongstreamState state) {
    final bloc = context.read<SongstreamBloc>();
    final isActuallyLoading = state is LoadingState ||
        (!bloc.getSongLoaded && bloc.getCurrentSongData != null);
    _isLoading.value = isActuallyLoading;
    _isPaused.value = state is PausedState || state is SongstreamInitial;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongstreamBloc, SongstreamState>(
      // Listen to ALL state changes
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is ErrorState) {
          context.read<SongstreamBloc>().add(PauseEvent());
          if (state.errorMessage != "Error fetching song: Connection aborted") {
            showSnackbar(context, state.errorMessage);
          }
        }
        // Always sync notifiers this fires even when buildWhen returns false.
        _syncWithState(state);
      },
      // Only rebuild the widget tree when the song ID changes.
      // Loading/paused icons are driven by ValueListenableBuilders above,
      // so they update instantly without needing a full BlocBuilder rebuild.
      buildWhen: (previous, current) {
        String? idFrom(SongstreamState s) {
          if (s is LoadingState) return s.songData.vId;
          if (s is PlayingState) return s.songData.vId;
          if (s is PausedState) return s.songData.vId;
          return null;
        }

        final prevId = idFrom(previous);
        final currId = idFrom(current);

        // Different song rebuild so the widget tree is fresh.
        if (prevId == null || currId == null || prevId != currId) return true;

        // Same song no structural rebuild needed; notifiers handle the icons.
        return false;
      },
      builder: (context, state) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return Center(
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: widget.screenSize * 0.0520,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).iconTheme.color,
                    strokeWidth: 7,
                  ),
                ),
              );
            }

            return Center(
              child: GestureDetector(
                onTap: () {
                  context.read<SongstreamBloc>().add(PlayPauseEvent());
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isPaused,
                  builder: (context, isPaused, _) {
                    return CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: widget.screenSize * 0.0520,
                      child: Center(
                        child: Icon(
                          isPaused
                              ? CupertinoIcons.play_fill
                              : CupertinoIcons.pause_fill,
                          size: widget.screenSize * 0.0650,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
