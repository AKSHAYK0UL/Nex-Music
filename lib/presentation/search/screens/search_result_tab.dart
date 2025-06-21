import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/search/screens/tabs/artisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/playlisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/songstab.dart';
import 'package:nex_music/presentation/search/screens/tabs/videostab.dart';

class SearchResultTab extends StatefulWidget {
  static const routeName = "/searchresulttab";
  const SearchResultTab({super.key});

  @override
  State<SearchResultTab> createState() => _SearchResultTabState();
}

class _SearchResultTabState extends State<SearchResultTab> {
  @override
  Widget build(BuildContext context) {
    final searchText = ModalRoute.of(context)!.settings.arguments as String;
    final screenSize = MediaQuery.sizeOf(context).height;
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: animatedText(
            text: searchText,
            style: Theme.of(context).textTheme.titleLarge!,
          ),
          bottom: ButtonsTabBar(
            splashColor: backgroundColor,
            backgroundColor: Colors.white24,
            unselectedBackgroundColor: secondaryColor,
            width: screenSize / 8,
            contentCenter: true,
            elevation: 0,
            labelStyle: Theme.of(context).textTheme.titleSmall,
            unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
            tabs: const [
              Tab(
                text: "Songs",
              ),
              Tab(
                text: "Videos",
              ),
              Tab(
                text: "Playlists",
              ),
              Tab(
                text: "Artists",
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          SongsTab(
            inputText: searchText,
            screenSize: screenSize,
          ),
          Videostab(
            inputText: searchText,
            screenSize: screenSize,
          ),
          PlaylistTab(
            inputText: searchText,
            screenSize: screenSize,
          ),
          ArtistTab(
            inputText: searchText,
            screenSize: screenSize,
          ),
        ]),
        bottomNavigationBar: MiniPlayer(screenSize: screenSize),
      ),
    );
  }
}
