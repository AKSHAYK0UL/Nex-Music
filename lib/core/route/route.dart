import 'package:flutter/material.dart';

import 'package:nex_music/presentation/search/screens/search_screen.dart';
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';

import 'package:nex_music/presentation/setting/screen/settting.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist_songs.dart';

Map<String, WidgetBuilder> routes = {
  // AudioPlayerScreen.routeName: (context) => const AudioPlayerScreen(),
  // PlaylistLoading.routeName: (context) => const PlaylistLoading(),
  // ShowPlaylist.routeName: (context) => ShowPlaylist(),
  ShowAllPlaylists.routeName: (context) => const ShowAllPlaylists(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  // SearchResultTab.routeName: (context) => const SearchResultTab(),
  // UserInfo.routeName: (context) => const UserInfo(),
  QualitySettingsScreen.routeName: (context) => const QualitySettingsScreen(),
  UserPlaylistSongs.routeName: (context) => const UserPlaylistSongs(),
  // Setting.routeName: (context) => Setting(),
};
