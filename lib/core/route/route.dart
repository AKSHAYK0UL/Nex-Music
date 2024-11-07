import 'package:flutter/material.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';

Map<String, WidgetBuilder> routes = {
  AudioPlayerScreen.routeName: (context) => AudioPlayerScreen(),
  ShowPlaylist.routeName: (context) => const ShowPlaylist(),
  ShowAllPlaylists.routeName: (context) => const ShowAllPlaylists(),
};
