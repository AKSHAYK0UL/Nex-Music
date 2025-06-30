import 'package:flutter/material.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart';
import 'package:nex_music/presentation/search/screens/search_result_tab.dart';
import 'package:nex_music/presentation/search/screens/search_screen.dart';
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';
import 'package:nex_music/presentation/setting/screen/phone_setting.dart';
import 'package:nex_music/presentation/setting/screen/settting.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist_songs.dart';

Map<String, WidgetBuilder> routes = {
  AudioPlayerScreen.routeName: (context) => const AudioPlayerScreen(),
  ShowPlaylist.routeName: (context) => const ShowPlaylist(),
  ShowAllPlaylists.routeName: (context) => const ShowAllPlaylists(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  SearchResultTab.routeName: (context) => const SearchResultTab(),
  UserInfo.routeName: (context) => const UserInfo(),
  QualitySettingsScreen.routeName: (context) => const QualitySettingsScreen(),
  UserPlaylistSongs.routeName: (context) => const UserPlaylistSongs(),
  Setting.routeName: (context) => Setting(),
};
