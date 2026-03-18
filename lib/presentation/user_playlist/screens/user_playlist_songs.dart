import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
import 'package:nex_music/bloc/user_playlist_songs_bloc/bloc/user_playlist_song_bloc.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/user_playlist_constants.dart';

class UserPlaylistSongs extends StatefulWidget {
  static const routeName = "/userplaylistsongs";
  final String? playlistName;
  final String? thumbnail;
  final int? colorValue;

  const UserPlaylistSongs({
    super.key,
    this.playlistName,
    this.thumbnail,
    this.colorValue,
  });

  @override
  State<UserPlaylistSongs> createState() => _UserPlaylistSongsState();
}

class _UserPlaylistSongsState extends State<UserPlaylistSongs> {
  final ScrollController _scrollController = ScrollController();
  List<Songmodel> _playlistSongs = [];
  bool _isCollapsed = false;

  String get _playlistName {
    if (widget.playlistName != null) return widget.playlistName!;
    return ModalRoute.of(context)?.settings.arguments as String? ?? 'Playlist';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<UserPlaylistSongBloc>()
          .add(GetuserPlaylistSongsEvent(playlistName: _playlistName));
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final screenSize = MediaQuery.sizeOf(context);
    final expandedHeight = screenSize.height * 0.45;
    final threshold = expandedHeight - kToolbarHeight - 20;

    if (_scrollController.offset > threshold && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= threshold && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final expandedHeight = screenSize.height * 0.45;
    final Color kPrimaryPink = const Color(0xFFFF2D55);

   
    final currentState = context.watch<ss.SongstreamBloc>().state;
    double bottomPadding = (currentState is ss.PausedState ||
            currentState is ss.PlayingState ||
            currentState is ss.LoadingState)
        ? 90.0
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<UserPlaylistSongBloc, UserPlaylistSongState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          bool isLoading = true;
          Stream<List<Songmodel>>? songStream;

          if (state is UserPlaylistSongSongsDataState) {
            isLoading = false;
            songStream = state.data;
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Songmodel>>(
            stream: songStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final songsData = snapshot.data ?? [];
              _playlistSongs = songsData;
              final int totalSongs = _playlistSongs.length;

              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                 
                  SliverAppBar(
                    expandedHeight: expandedHeight,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    scrolledUnderElevation: 4.0,
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    leading: GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Icon(
                          CupertinoIcons.chevron_back,
                          color: kPrimaryPink,
                          size: 28,
                        ),
                      ),
                    ),
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isCollapsed ? 1.0 : 0.0,
                      child: Text(
                        _playlistName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                     
                      IconButton(
                        onPressed: () async {
                          await Share.share(
                              "Check out my playlist: $_playlistName");
                        },
                        icon: Icon(
                          CupertinoIcons.share,
                          color: kPrimaryPink,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                         
                          Container(
                            height: 30,
                            color: const Color(0xFF1C1C44),
                            child: widget.thumbnail != null &&
                                    widget.thumbnail!.isNotEmpty
                                ? cacheImage(
                                    imageUrl: widget.thumbnail!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    isRecommendedPlaylist: true,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.colorValue != null
                                              ? Color(widget.colorValue!)
                                              : kPrimary,
                                          widget.colorValue != null
                                              ? Color(widget.colorValue!)
                                                  .withOpacity(0.6)
                                              : kPrimary.withOpacity(0.6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.music_note,
                                          color: Colors.white, size: 80),
                                    ),
                                  ),
                          ),
                         
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.85),
                                ],
                                stops: const [0.0, 0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                         
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                               
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    _playlistName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'System',
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$totalSongs SONGS",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                               
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                     
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showSnackbar(
                                                  context, "Added to library");
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.add,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                         
                                        ],
                                      ),
                                     
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (_playlistSongs.isNotEmpty) {
                                                final shuffled =
                                                    List<Songmodel>.from(
                                                        _playlistSongs)
                                                      ..shuffle();
                                                context
                                                    .read<ss.SongstreamBloc>()
                                                    .add(
                                                      ss.PlaySongFromPlaylistEvent(
                                                        songData:
                                                            shuffled.first,
                                                        songIndex: 0,
                                                        playlistSongs: shuffled,
                                                      ),
                                                    );
                                                showSnackbar(context,
                                                    "Shuffling $_playlistName");
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.shuffle,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () {
                                              if (_playlistSongs.isNotEmpty) {
                                                context
                                                    .read<ss.SongstreamBloc>()
                                                    .add(
                                                      ss.PlaySongFromPlaylistEvent(
                                                        songData: _playlistSongs
                                                            .first,
                                                        songIndex: 0,
                                                        playlistSongs:
                                                            _playlistSongs,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: Container(
                                              height: 56,
                                              width: 56,
                                              decoration: BoxDecoration(
                                                color: kPrimaryPink,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: kPrimaryPink
                                                        .withOpacity(0.4),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ],
                                              ),
                                              child: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 4.0),
                                                child: Icon(
                                                  CupertinoIcons.play_fill,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                 
                  if (_playlistSongs.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No Song found!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          return RecentSongTile(
                            songData: _playlistSongs[i],
                            songIndex: i,
                            showDelete: true,
                            tabRouteENUM: TabRouteENUM.playlist,
                            playlistSongs: _playlistSongs,
                            playlistName: _playlistName,
                          );
                        },
                        childCount: _playlistSongs.length,
                      ),
                    ),

                 
                  SliverPadding(
                      padding: EdgeInsets.only(bottom: bottomPadding + 20)),
                ],
              );
            },
          );
        },
      ),
     
    );
  }
}
