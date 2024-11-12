import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

Route slideTransitionRoute({
  required BuildContext context,
  required Songmodel songData,
  required SongMiniPlayerRoute route,
}) {
  return PageRouteBuilder(
    settings: RouteSettings(
      name: AudioPlayerScreen.routeName,
      arguments: {
        "songindex": context.read<SongstreamBloc>().getFirstSongPlayedIndex,
        'songdata': songData,
        'route': route,
      },
    ),
    pageBuilder: (context, animation, _) => const AudioPlayerScreen(),
    transitionsBuilder: (context, animation, _, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
