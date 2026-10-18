import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart' as songbloc;
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/presentation/search/screens/tabs/albumtab.dart';
import 'package:nex_music/presentation/search/screens/tabs/artisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/playlisttab.dart';
import 'package:nex_music/presentation/search/screens/tabs/songstab.dart';
import 'package:nex_music/presentation/search/screens/tabs/videostab.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

class SearchResultTab extends StatefulWidget {
  static const routeName = "/searchresulttab";
  final String searchText;
  final int initialTabIndex;

  const SearchResultTab({
    super.key,
    required this.searchText,
    this.initialTabIndex = 0,
  });

  @override
  State<SearchResultTab> createState() => _SearchResultTabState();
}

class _SearchResultTabState extends State<SearchResultTab>
    with SingleTickerProviderStateMixin {
  late final songbloc.SongBloc _songBloc;
  late final VideoBloc _videoBloc;
  late final SearchAlbumBloc _searchAlbumBloc;
  late final SearchedplaylistBloc _searchedplaylistBloc;
  late final ArtistBloc _artistBloc;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final repo = context.read<Repository>();
    _songBloc = songbloc.SongBloc(repo)
      ..add(songbloc.SeachInSongEvent(inputText: widget.searchText));
    _videoBloc = VideoBloc(repo);
    _searchAlbumBloc = SearchAlbumBloc(repo);
    _searchedplaylistBloc = SearchedplaylistBloc(repo);
    _artistBloc = ArtistBloc(repo);
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SearchResultTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchText != widget.searchText) {
      _songBloc.add(songbloc.SeachInSongEvent(inputText: widget.searchText));
      _videoBloc.add(SearchInVideoEvent(inputText: widget.searchText));
      _searchAlbumBloc.add(SearchAlbumsEvent(inputText: widget.searchText));
      _searchedplaylistBloc.add(SearchInPlaylistEvent(inputText: widget.searchText));
      _artistBloc.add(GetArtistEvent(inputText: widget.searchText));
    }
  }

  @override
  void dispose() {
    _songBloc.close();
    _videoBloc.close();
    _searchAlbumBloc.close();
    _searchedplaylistBloc.close();
    _artistBloc.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<songbloc.SongBloc>.value(value: _songBloc),
        BlocProvider<VideoBloc>.value(value: _videoBloc),
        BlocProvider<SearchAlbumBloc>.value(value: _searchAlbumBloc),
        BlocProvider<SearchedplaylistBloc>.value(value: _searchedplaylistBloc),
        BlocProvider<ArtistBloc>.value(value: _artistBloc),
      ],
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
                    context.pushNamed(
                      RouterName.searchName,
                      extra: widget.searchText,
                    );
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
                        placeholderStyle:
                            TextStyle(color: theme.colorScheme.onSurface),
                        itemColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 2,
                  dividerColor: theme.dividerColor,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            controller: _tabController,
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
