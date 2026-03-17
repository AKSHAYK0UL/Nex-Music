
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';
import 'package:share_plus/share_plus.dart';

class ShowPlaylist extends StatefulWidget {
  static const routeName = "/showplaylist";
  final PlayListmodel playlistData;

  const ShowPlaylist({super.key, required this.playlistData});

  @override
  State<ShowPlaylist> createState() => _ShowPlaylistState();
}

class _ShowPlaylistState extends State<ShowPlaylist> {
  final ScrollController _scrollController = ScrollController();

  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    context
        .read<PlaylistBloc>()
        .add(GetPlaylistEvent(playlistId: widget.playlistData.playListId));

    // Add listener to handle title visibility
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    //=
    final screenSize = MediaQuery.sizeOf(context);
    final expandedHeight = screenSize.height * 0.52;
    final threshold =
        expandedHeight - kToolbarHeight - 20; 

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

    // Calculate bottom padding for the mini-player
    final currentState = context.watch<ss.SongstreamBloc>().state;
    double bottomPadding = (currentState is ss.PausedState ||
            currentState is ss.PlayingState ||
            currentState is ss.LoadingState)
        ? 90.0
        : 0.0;

    return BlocBuilder<PlaylistBloc, PlaylistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, playlistState) {
        if (playlistState is ErrorState) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                playlistState.errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        // Data Extraction
        final bool isLoading = playlistState is! PlaylistDataState;
        final List<Songmodel> songs = playlistState is PlaylistDataState
            ? playlistState.playlistSongs
            : [];
        final int totalSongs =
            playlistState is PlaylistDataState ? playlistState.totalSongs : 0;
        final bool isLoadingMore = playlistState is PlaylistDataState
            ? playlistState.isLoading
            : false;

        // Trigger load more if needed
        if (playlistState is PlaylistDataState) {
          context.read<PlaylistBloc>().add(
                LoadMoreSongsEvent(playlistId: widget.playlistData.playListId),
              );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. The Sliver App Bar (Collapsing Header)
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
                  onTap: () => context.pop(),
                  child: Container(
                    color: Colors.transparent,
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: kPrimaryPink,
                      size: 28,
                    ),
                  ),
                ),

                // Title visible only when collapsed using AnimatedOpacity
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isCollapsed ? 1.0 : 0.0,
                  child: Text(
                    widget.playlistData.playlistName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  // --- SHARE BUTTON ---
                  IconButton(
                    onPressed: () async {
                      await Share.share(
                        "Check out this playlist: ${widget.playlistData.playlistName}\nhttps://music.youtube.com/playlist?list=${widget.playlistData.playListId}",
                      );
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
                      // Background Image
                      Container(
                        height: 30,
                        color: const Color(0xFF1C1C44),
                        child: cacheImage(
                            imageUrl: widget.playlistData.thumbnail,
                            width: double.infinity,
                            height: double.infinity,
                            isRecommendedPlaylist: true),
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Expanded Header Content (Title, Counts, Buttons)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Metadata
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.playlistData.playlistName,
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
                            // const SizedBox(height: 6),
                            // Text(
                            //  widget.playlistData.artistBasic.name.toUpperCase(),
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: Colors.white.withValues(alpha:0.7),
                            //     fontSize: 11,
                            //     fontWeight: FontWeight.w600,
                            //     letterSpacing: 0.5,

                            //   ),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            const SizedBox(height: 6),
                            Text(
                              isLoading ? "Loading..." : "$totalSongs SONGS",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),

                            // Control Row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left Side: Add & Info
                                  Row(
                                    children: [
                                      // Add Button
                                      GestureDetector(
                                        onTap: () {
                                          showSnackbar(
                                              context, "Added to library");
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.add,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // --- INFO BUTTON ---
                                      GestureDetector(
                                        onTap: () => _showSongInfoDialog(
                                          context,
                                          songs,
                                          totalSongs,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.info,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Right Side: Shuffle & Play
                                  Row(
                                    children: [
                                      // Shuffle Button
                                      GestureDetector(
                                        onTap: () {
                                          if (songs.isNotEmpty) {
                                            final shuffled =
                                                List<Songmodel>.from(songs)
                                                  ..shuffle();
                                            context
                                                .read<ss.SongstreamBloc>()
                                                .add(ss
                                                    .PlaySongFromPlaylistEvent(
                                                  songData: shuffled.first,
                                                  songIndex: 0,
                                                  playlistSongs: shuffled,
                                                ));
                                            showSnackbar(
                                                context, "Shuffling...");
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
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
                                      // Play Button
                                      GestureDetector(
                                        onTap: () {
                                          if (songs.isNotEmpty) {
                                            context
                                                .read<ss.SongstreamBloc>()
                                                .add(ss
                                                    .PlaySongFromPlaylistEvent(
                                                  songData: songs.first,
                                                  songIndex: 0,
                                                  playlistSongs: songs,
                                                ));
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
                                                color: kPrimaryPink.withValues(
                                                    alpha: 0.4),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              )
                                            ],
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
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

              // 2. The List Content
              isLoading
                  ? SliverToBoxAdapter(child: _buildLoadingIndicator())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= songs.length) {
                            // Loading spinner at the bottom
                            return isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CupertinoActivityIndicator(),
                                  )
                                : const SizedBox.shrink();
                          }
                          return RecentSongTile(
                            showDelete: false,
                            songData: songs[index],
                            songIndex: index,
                            playlistSongs: songs,
                            tabRouteENUM: TabRouteENUM.playlist,
                          );
                        },
                        childCount: songs.length + (isLoadingMore ? 1 : 0),
                      ),
                    ),

              // 3. Bottom Padding for Player
              SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomPadding + 20)),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildLoadingIndicator() {
    return Column(
      children: List.generate(
        6,
        (index) => Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Apple Style Info Dialog ---
  void _showSongInfoDialog(
      BuildContext context, List<Songmodel> songs, int totalSongs) {
    // Logic to extract all unique artist names
    String allArtists = "Various Artists";
    if (songs.isNotEmpty) {
      final Set<String> artistsSet = {};
      // Add the playlist creator/main artist first
      artistsSet.add(widget.playlistData.artistBasic.name);

      try {
        // for (var s in songs) { artistsSet.add(s.artistName); }
      } catch (e) {
        // Fallback
      }
      allArtists = artistsSet.join(", ");
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: 300,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9).withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Content (Scrollable)
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: Column(
                              children: [
                                // Thumbnail Shadow
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: cacheImage(
                                      imageUrl: widget.playlistData.thumbnail,
                                      width: 140,
                                      height: 140,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Playlist Name
                                Text(
                                  widget.playlistData.playlistName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                    fontFamily: 'System',
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Metadata
                                Text(
                                  "$totalSongs Songs",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Divider
                                Divider(
                                  height: 1,
                                  color: Colors.grey.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 10),

                                // Artists Header
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ARTISTS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Artists List Text
                                Text(
                                  allArtists,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Actions (Pinned)
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Close",
                                    style: TextStyle(
                                      color: Color(0xFF007AFF), // iOS Blue
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
