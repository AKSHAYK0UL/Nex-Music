import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/bloc/full_artist_playlist_bloc/bloc/full_artist_playlist_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/full_artist_video_bloc/bloc/full_artist_video_bloc_bloc.dart';
import 'package:nex_music/bloc/saved_artists_bloc/bloc/saved_artists_bloc.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/artist/artist_album.dart';
import 'package:nex_music/presentation/home/artist/artist_playlist.dart';
import 'package:nex_music/presentation/home/artist/artist_songs.dart';
import 'package:nex_music/presentation/home/artist/artist_videos.dart';

class ArtistFullScreen extends StatefulWidget {
  final ArtistModel artist;
  const ArtistFullScreen({required this.artist, super.key});

  @override
  State<ArtistFullScreen> createState() => _ArtistFullScreenState();
}

class _ArtistFullScreenState extends State<ArtistFullScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    final artistId = widget.artist.artist.artistId;
    final artistName = widget.artist.artist.name;

    if (artistId != null) {
      // Reset all blocs to clear old artist's data
      context.read<FullArtistSongBloc>().add(ResetArtistSongsEvent());
      context.read<FullArtistVideoBloc>().add(SetFullArtistVideoBlocInitialEvent());
      context.read<FullArtistAlbumBloc>().add(SetFullartistalbumInitialEvent());
      context.read<FullArtistPlaylistBloc>().add(SetFullArtistPlaylistInitialEvent());

      // Fetch new data
      context
          .read<FullArtistSongBloc>()
          .add(GetArtistSongsEvent(artistId: artistId));
      context
          .read<FullArtistVideoBloc>()
          .add(GetArtistVideosEvent(inputText: artistName));
      context
          .read<FullArtistAlbumBloc>()
          .add(GetArtistAlbumsEvent(artist: widget.artist));
      context
          .read<FullArtistPlaylistBloc>()
          .add(GetFullArtistPlaylistEvent(inputText: artistName));
    }

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
    final screenSize = MediaQuery.sizeOf(context).height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                stretch: true,
                elevation: 0,
                expandedHeight: screenSize * 0.45,
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back,
                      color: Colors.red, size: 28),
                  onPressed: () => context.pop(),
                ),
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isCollapsed ? 1.0 : 0.0,
                  child: Text(
                    widget.artist.artist.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                actions: [
                  BlocBuilder<SavedArtistsBloc, SavedArtistsState>(
                    builder: (context, state) {
                      bool isSaved = false;
                      final artistId = widget.artist.artist.artistId;
                      if (artistId != null) {
                        if (state is IsArtistSavedState &&
                            state.artistId == artistId) {
                          isSaved = state.isSaved;
                        } else {
                          context.read<SavedArtistsBloc>().add(
                                IsArtistSavedEvent(artistId: artistId),
                              );
                        }
                      }
                      return IconButton(
                        icon: Icon(
                          isSaved
                              ? CupertinoIcons.person_crop_circle_badge_minus
                              : CupertinoIcons.person_crop_circle_badge_plus,
                          color: isSaved ? const Color(0xFFFF3B30) : Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          if (artistId != null) {
                            if (isSaved) {
                              context.read<SavedArtistsBloc>().add(
                                    RemoveFromSavedArtistsEvent(
                                        artistId: artistId),
                                  );
                            } else {
                              context.read<SavedArtistsBloc>().add(
                                    AddToSavedArtistsEvent(
                                        artist: widget.artist),
                                  );
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                centerTitle: false,
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
                        color: const Color(0xFF1C1C44),
                        child: cacheImage(
                          imageUrl: widget.artist.thumbnail,
                          width: double.infinity,
                          height: double.infinity,
                          islocal: false,
                        ),
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
                              Colors.black.withValues(alpha: 0.5),
                              Colors.black.withValues(alpha: 0.9),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Artist Name
                      Positioned(
                        bottom: 60, 
                        left: 20,
                        right: 20,
                        child: Text(
                          widget.artist.artist.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'System',
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kTextTabBarHeight),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      indicatorColor: Colors.redAccent,
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
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ArtistSongs(artist: widget.artist),
              ArtistVideos(artist: widget.artist),
              ArtistAlbum(artist: widget.artist),
              ArtistPlaylist(artist: widget.artist),
            ],
          ),
        ),
      ),
    );
  }
}
