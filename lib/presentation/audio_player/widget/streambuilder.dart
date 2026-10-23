import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/model/audioplayerstream.dart';

class StreamBuilderWidget extends StatefulWidget {
  final double screenSize;
  const StreamBuilderWidget({
    super.key,
    required this.screenSize,
  });

  @override
  State<StreamBuilderWidget> createState() => _StreamBuilderWidgetState();
}

class _StreamBuilderWidgetState extends State<StreamBuilderWidget> {
  late SongstreamBloc _songstreamBloc;
  late StreamSubscription<AudioPlayerStream> _streamSubscription;

  // ValueNotifier drives the ProgressBar  we fully control what is displayed.
  late final ValueNotifier<Duration> _displayPosition;
  late final ValueNotifier<Duration> _displayBuffered;

  // While non-null we suppress stream updates that are lower than this target
  // (the "flash to zero" that just_audio emits during a seek).
  Duration? _pendingSeekPosition;

  @override
  void initState() {
    super.initState();
    _songstreamBloc = context.read<SongstreamBloc>();

    final initial = _songstreamBloc.currentAudioPlayerStream;
    _displayPosition = ValueNotifier(initial.position);
    _displayBuffered = ValueNotifier(initial.bufferPosition);

    _streamSubscription =
        _songstreamBloc.getAudioPlayerStreamData.listen(_onStreamEvent);
  }

  void _onStreamEvent(AudioPlayerStream event) {
    final incoming = event.position;

    if (_pendingSeekPosition != null) {
      if (incoming < _pendingSeekPosition! - const Duration(seconds: 1)) {
        return;
      }
      _pendingSeekPosition = null;
    }

    _displayPosition.value = incoming;
    _displayBuffered.value = event.bufferPosition;
  }

  void _handleSeek(Duration value) {
    // Immediately show the tapped position — no waiting for the stream.
    _displayPosition.value = value;
    _pendingSeekPosition = value;
    _songstreamBloc.add(SeekToEvent(position: value));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _displayPosition.dispose();
    _displayBuffered.dispose();
    super.dispose();
  }

  // Parse "mm:ss" or "hh:mm:ss" duration string to Duration.
  Duration _parseDuration(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const Duration(seconds: 1);
    final parts = raw.trim().split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: m, seconds: s);
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: h, minutes: m, seconds: s);
    }
    return const Duration(seconds: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongstreamBloc, SongstreamState>(
      // Rebuild only when loading state starts/ends or song ID changes.
      buildWhen: (previous, current) {
        String? idFrom(SongstreamState s) {
          if (s is LoadingState) return s.songData.vId;
          if (s is PlayingState) return s.songData.vId;
          if (s is PausedState) return s.songData.vId;
          return null;
        }

        final prevId = idFrom(previous);
        final currId = idFrom(current);

        // Different song (or no song ID yet)  always rebuild.
        if (prevId == null || currId == null || prevId != currId) return true;

        if ((previous is PlayingState || previous is PausedState) &&
            current is LoadingState) {
          return false;
        }

        return true;
      },

      builder: (context, blocState) {
        final isLoading = blocState is LoadingState;

        // Loading: reset display to zero, show new-song duration
        if (isLoading) {
          _pendingSeekPosition = null;
          _displayPosition.value = Duration.zero;
          _displayBuffered.value = Duration.zero;

          final loadingSong = blocState.songData;

          final total = _parseDuration(loadingSong.duration);

          return _buildBar(
            context,
            progress: Duration.zero,
            buffered: Duration.zero,
            total: total > Duration.zero ? total : const Duration(seconds: 1),
            onSeek: null,
          );
        }

        String? songDurationStr;
        if (blocState is PlayingState) {
          songDurationStr = blocState.songData.duration;
        }
        if (blocState is PausedState) {
          songDurationStr = blocState.songData.duration;
        }
        final metadataDuration = songDurationStr != null
            ? _parseDuration(songDurationStr)
            : Duration.zero;
        final duration = metadataDuration > Duration.zero
            ? metadataDuration
            : (_songstreamBloc.songDuration > Duration.zero
                ? _songstreamBloc.songDuration
                : const Duration(seconds: 1));

        return ValueListenableBuilder<Duration>(
          valueListenable: _displayPosition,
          builder: (context, position, _) {
            return ValueListenableBuilder<Duration>(
              valueListenable: _displayBuffered,
              builder: (context, buffered, _) {
                return _buildBar(
                  context,
                  progress: position,
                  buffered: buffered,
                  total: duration,
                  onSeek: _handleSeek,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required Duration progress,
    required Duration buffered,
    required Duration total,
    required ValueChanged<Duration>? onSeek,
  }) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.screenSize * 0.0388),
        child: SizedBox(
          height: 48,
          child: ProgressBar(
            progress: progress,
            buffered: buffered,
            total: total,
            barHeight: 5,
            thumbRadius: 6,
            timeLabelLocation: TimeLabelLocation.below,
            timeLabelPadding: 6,
            baseBarColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
            bufferedBarColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            progressBarColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            thumbColor: Theme.of(context).colorScheme.onSurface,
            timeLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            onSeek: onSeek,
          ),
        ),
      ),
    );
  }
}
