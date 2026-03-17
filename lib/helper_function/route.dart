import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

Route slideTransitionRoute({
  required BuildContext context,
  required Songmodel songData,
  required SongMiniPlayerRoute route,
  required ThumbnailQuality quality,
}) {
  return PageRouteBuilder(
    settings: RouteSettings(
      name: AudioPlayerScreen.routeName,
      arguments: {
        "songindex": context.read<SongstreamBloc>().getFirstSongPlayedIndex,
        'songdata': songData,
        'route': route,
        "quality": quality,
      },
    ),
    opaque: false,
    pageBuilder: (context, animation, _) =>  AudioPlayerScreen(
      routeData: { "songindex":   0,
        'songdata': songData,
        'route': route,
        "quality": quality },
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var slideTween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      return Stack(
        children: [
          // Background blur effect
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: animation.value * 10,
                  sigmaY: animation.value * 10,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: animation.value * 0.3),
                ),
              );
            },
          ),
          // Slide transition for the audio player
          SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}



// Alternative route without context (for backward compatibility)
Route slideTransitionRouteSimple({
  required Songmodel songData,
  required SongMiniPlayerRoute route,
  int? songIndex,
  ThumbnailQuality? quality,
}) {
  return PageRouteBuilder(
    settings: RouteSettings(
      name: AudioPlayerScreen.routeName,
      arguments: {
        "songindex": songIndex ?? 0,
        'songdata': songData,
        'route': route,
        "quality": quality ?? ThumbnailQuality.medium,
      },
    ),
    opaque: false,
    pageBuilder: (context, animation, _) =>  AudioPlayerScreen(
      routeData: {
         "songindex": songIndex ?? 0,
        'songdata': songData,
        'route': route,
        "quality": quality ?? ThumbnailQuality.medium,
      },
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var slideTween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      return Stack(
        children: [
          // Background blur effect
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: animation.value * 10,
                  sigmaY: animation.value * 10,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: animation.value * 0.3),
                ),
              );
            },
          ),
          // Slide transition for the audio player
          SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}
