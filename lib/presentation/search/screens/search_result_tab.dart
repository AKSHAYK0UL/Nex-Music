
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';

import 'package:nex_music/presentation/search/screens/tabs/albumtab.dart';
import 'package:nex_music/presentation/search/screens/tabs/artisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/playlisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/songstab.dart';
import 'package:nex_music/presentation/search/screens/tabs/videostab.dart';

class SearchResultTab extends StatefulWidget {
  static const routeName = "/searchresulttab";
  final String searchText;
  const SearchResultTab({super.key, required this.searchText});

  @override
  State<SearchResultTab> createState() => _SearchResultTabState();
}

class _SearchResultTabState extends State<SearchResultTab> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: true,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.red, size: 20),
                  onPressed: () => context.pop(),
                ),
                // title: Text(
                //   widget.searchText,
                //   style: const TextStyle(
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 17),
                // ),
                title: GestureDetector(
                  onTap: () {
                     context.pushNamed(RouterName.searchName,extra: widget.searchText);
                    // context.pop(true);
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, right: 16.0, bottom: 10.0, top: 10.0),
                      child: CupertinoSearchTextField(
                        enabled: false,
                        cursorColor: Colors.red,
                        autofocus: false,
                        placeholder: widget.searchText,
                        placeholderStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),

                bottom: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor:
                      Colors.redAccent, // Apple Music's signature accent
                  indicatorWeight: 2,
                  dividerColor: Colors.grey.withValues(alpha: 0.2),
                  labelColor: Colors.redAccent,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.2),
                  tabs: const [
                    Tab(text: "Songs"),
                    Tab(text: "Videos"),
                    Tab(text: "Albums"),
                    Tab(text: "Playlists"),
                    Tab(text: "Artists"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              SongsTab(inputText: widget.searchText, screenSize: screenSize),
              Videostab(inputText: widget.searchText, screenSize: screenSize),
              AlbumTab(inputText: widget.searchText, screenSize: screenSize),
              PlaylistTab(inputText: widget.searchText, screenSize: screenSize),
              ArtistTab(inputText: widget.searchText, screenSize: screenSize),
            ],
          ),
        ),
      ),
    );
  }
}
