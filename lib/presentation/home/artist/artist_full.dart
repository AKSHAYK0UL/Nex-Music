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
import 'package:nex_music/repository/home_repo/repository.dart';

class ArtistFullScreen extends StatefulWidget {
  final ArtistModel artist;
  const ArtistFullScreen({required this.artist, super.key});

  @override
  State<ArtistFullScreen> createState() => _ArtistFullScreenState();
}

class _ArtistFullScreenState extends State<ArtistFullScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  late ArtistModel _currentArtist;

  @override
  void initState() {
    super.initState();
    _currentArtist = widget.artist;
    final artistId = _currentArtist.artist.artistId;
    final artistName = _currentArtist.artist.name;

    // Reset all blocs to clear old artist's data
    context.read<FullArtistSongBloc>().add(ResetArtistSongsEvent());
    context.read<FullArtistVideoBloc>().add(SetFullArtistVideoBlocInitialEvent());
    context.read<FullArtistAlbumBloc>().add(SetFullartistalbumInitialEvent());
    context.read<FullArtistPlaylistBloc>().add(SetFullArtistPlaylistInitialEvent());

    // Fetch new data
    if (artistId != null && artistId.isNotEmpty) {
      context
          .read<FullArtistSongBloc>()
          .add(GetArtistSongsEvent(artistId: artistId));
    }
    context
        .read<FullArtistVideoBloc>()
        .add(GetArtistVideosEvent(inputText: artistName));
    context
        .read<FullArtistAlbumBloc>()
        .add(GetArtistAlbumsEvent(artist: _currentArtist));
    context
        .read<FullArtistPlaylistBloc>()
        .add(GetFullArtistPlaylistEvent(inputText: artistName));

    _scrollController.addListener(_scrollListener);

    // If thumbnail is empty or artistId is missing, resolve official artist details
    if (_currentArtist.thumbnail.isEmpty || artistId == null || artistId.isEmpty) {
      _loadArtistDetails();
    }
  }

  Future<void> _loadArtistDetails() async {
    try {
      final resolved =
          await context.read<Repository>().resolveArtist(_currentArtist);
      if (!mounted) return;
      final hadNoId = _currentArtist.artist.artistId == null ||
          _currentArtist.artist.artistId!.isEmpty;
      if (resolved.thumbnail != _currentArtist.thumbnail ||
          resolved.artist.artistId != _currentArtist.artist.artistId) {
        setState(() {
          _currentArtist = resolved;
        });

        // If artistId was previously missing, now fetch artist songs with the resolved ID
        if (hadNoId &&
            resolved.artist.artistId != null &&
            resolved.artist.artistId!.isNotEmpty) {
          context
              .read<FullArtistSongBloc>()
              .add(GetArtistSongsEvent(artistId: resolved.artist.artistId!));
          context
              .read<FullArtistAlbumBloc>()
              .add(GetArtistAlbumsEvent(artist: _currentArtist));
        }
      }
    } catch (_) {}
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

  Widget _buildArtistImage() {
    if (_currentArtist.thumbnail.isNotEmpty) {
      return cacheImage(
        imageUrl: _currentArtist.thumbnail,
        width: double.infinity,
        height: double.infinity,
        islocal: false,
      );
    }

    return Container(
      color: const Color(0xFF1C1C44),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Icon(
          CupertinoIcons.person_solid,
          size: 80,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    _currentArtist.artist.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                actions: [
                  BlocBuilder<SavedArtistsBloc, SavedArtistsState>(
                    builder: (context, state) {
                      bool isSaved = false;
                      final artistId = _currentArtist.artist.artistId;
                      if (artistId != null && artistId.isNotEmpty) {
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
                          if (artistId != null && artistId.isNotEmpty) {
                            if (isSaved) {
                              context.read<SavedArtistsBloc>().add(
                                    RemoveFromSavedArtistsEvent(
                                        artistId: artistId),
                                  );
                            } else {
                              context.read<SavedArtistsBloc>().add(
                                    AddToSavedArtistsEvent(
                                        artist: _currentArtist),
                                  );
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                centerTitle: true,
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
                        child: _buildArtistImage(),
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
                          _currentArtist.artist.name,
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      indicatorColor: Colors.redAccent,
                      indicatorWeight: 2,
                      dividerColor: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      labelColor: Colors.redAccent,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              ArtistSongs(artist: _currentArtist),
              ArtistVideos(artist: _currentArtist),
              ArtistAlbum(artist: _currentArtist),
              ArtistPlaylist(artist: _currentArtist),
            ],
          ),
        ),
      ),
    );
  }
}
