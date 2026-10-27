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
  // Tracks the live total duration reported by the audio player.
  late final ValueNotifier<Duration> _displayTotal;

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
    _displayTotal = ValueNotifier(Duration.zero);

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
    // Update live total duration (non-zero values only)
    if (event.totalDuration > Duration.zero) {
      _displayTotal.value = event.totalDuration;
    }
  }

  void _handleSeek(Duration value) {
    // Immediately show the tapped position no waiting for the stream.
    _displayPosition.value = value;
    _pendingSeekPosition = value;
    _songstreamBloc.add(SeekToEvent(position: value));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _displayPosition.dispose();
    _displayBuffered.dispose();
    _displayTotal.dispose();
    super.dispose();
  }

  // Parse "mm:ss" or "hh:mm:ss" duration string to Duration.
  Duration _parseDuration(String? raw) {
    if (raw == null || raw.trim().isEmpty) return Duration.zero;
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
    return Duration.zero;
  }

  // Pick the best duration: metadata string -> live stream -> bloc field -> fallback 0s
  Duration _effectiveDuration(Duration metadataDuration) {
    if (metadataDuration > Duration.zero) return metadataDuration;
    if (_displayTotal.value > Duration.zero) return _displayTotal.value;
    if (_songstreamBloc.songDuration > Duration.zero) {
      return _songstreamBloc.songDuration;
    }
    return const Duration(seconds: 0);
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
          // Reset live total so previous song's duration doesn't show over
          _displayTotal.value = Duration.zero;

          final loadingSong = blocState.songData;
          final metadataDuration = _parseDuration(loadingSong.duration);

          return _buildBar(
            context,
            progress: Duration.zero,
            buffered: Duration.zero,
            total: metadataDuration > Duration.zero
                ? metadataDuration
                : const Duration(seconds: 1),
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
        final metadataDuration = _parseDuration(songDurationStr);

        // Wrap in _displayTotal listener so the bar auto-updates when the
        // audio player reports the real duration (fixes artist songs with no
        // pre-loaded duration).
        return ValueListenableBuilder<Duration>(
          valueListenable: _displayTotal,
          builder: (context, liveDuration, _) {
            final effectiveDuration = _effectiveDuration(metadataDuration);

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
                      total: effectiveDuration,
                      onSeek: _handleSeek,
                    );
                  },
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
