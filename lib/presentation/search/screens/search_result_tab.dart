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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: theme.colorScheme.primary, size: 20),
                  onPressed: () => context.pop(),
                ),
                title: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.pushNamed(RouterName.searchName,
                        extra: widget.searchText);
                  },
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, right: 16.0, bottom: 10.0, top: 10.0),
                      child: CupertinoSearchTextField(
                        enabled: true,
                        cursorColor: theme.colorScheme.primary,
                        autofocus: false,
                        placeholder: widget.searchText,
                        placeholderStyle: TextStyle(color: theme.colorScheme.onSurface),
                        itemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),

                bottom: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 2,
                  dividerColor: theme.dividerColor,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
