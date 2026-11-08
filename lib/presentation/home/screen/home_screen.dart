import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/new_components/section_header.dart';
import 'package:nex_music/presentation/home/widget/songcolumview.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomesectionBloc, HomesectionState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Loading();
        }

        if (state is ErrorState) {
          return Scaffold(
            body: Center(
              child: Text(
                state.errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        if (state is HomeSectionStateData) {
          return Scaffold(
            body: _HomeLayout(
              child: _buildBody(context, state),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

//  BODY

Widget _buildBody(
  BuildContext context,
  HomeSectionStateData state,
) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),

          // Quick Picks always shown at the top
          if (state.quickPicks.isNotEmpty) ...[
            const _SubHeader(title: "Top Picks For You"),
            FeaturedCarousel(songs: state.quickPicks),
            const SizedBox(height: 26),
          ],

          // Dynamic sections render exactly what getHome(country:'IN') returned
          ...state.homeSections
              .where((s) =>
                  // Skip top_picks since we render it as the featured carousel above
                  s.stableTitle != 'top_picks' &&
                  s.stableTitle != 'recommended' &&
                  s.contents.isNotEmpty)
              .map((section) => _buildSection(context, section)),

          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}

// Converts a HomeSection from getHome() into a carousel widget.
// Albums -> AlbumCarousel, everything else -> PlaylistCarousel
Widget _buildSection(BuildContext context, HomeSection section) {
  // Separate albums, playlists, and songs from the section contents
  final albums = <PlayListmodel>[];
  final playlists = <PlayListmodel>[];
  final songs = <Songmodel>[];

  for (final item in section.contents) {
    if (item is AlbumDetailed) {
      albums.add(PlayListmodel(
        playListId: item.albumId.isNotEmpty ? item.albumId : item.playlistId,
        playlistName: item.name,
        artistBasic: item.artist,
        thumbnail: getThumbnail(item.thumbnails),
      ));
    } else if (item is PlaylistDetailed) {
      if (item.playlistId.startsWith('MPREb_') ||
          item.playlistId.startsWith('OLAK')) {
        // Album  as playlist
        albums.add(PlayListmodel(
          playListId: item.playlistId,
          playlistName: item.name,
          artistBasic: item.artist,
          thumbnail: getThumbnail(item.thumbnails),
        ));
      } else {
        playlists.add(PlayListmodel(
          playListId: item.playlistId,
          playlistName: item.name,
          artistBasic: item.artist,
          thumbnail: getThumbnail(item.thumbnails),
        ));
      }
    } else if (item is SongDetailed) {
      songs.add(Songmodel(
        vId: item.videoId,
        songName: item.name,
        artist: item.artist,
        thumbnail: getThumbnail(item.thumbnails),
        duration: timeFormate(item.duration ?? 0),
      ));
    }
  }

  //  If this is a song section (e.g. Trending, New music videos)
  if (songs.isNotEmpty && albums.isEmpty && playlists.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeader(title: section.title),
        FeaturedCarousel(songs: songs),
        const SizedBox(height: 26),
      ],
    );
  }

  //  Decide album vs playlist
  final isAlbumSection = albums.isNotEmpty && playlists.isEmpty;
  final displayItems =
      isAlbumSection ? albums : (playlists.isNotEmpty ? playlists : albums);

  if (displayItems.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(
        title: section.title,
        onTap: () => context.push(
          RouterPath.showAllGenericRoute,
          extra: {
            'title': section.title,
            'items': displayItems,
            'isAlbum': isAlbumSection,
          },
        ),
      ),
      isAlbumSection
          ? AlbumCarousel(albums: displayItems.take(7).toList())
          : PlaylistCarousel(playlists: displayItems.take(7).toList()),
      const SizedBox(height: 26),
    ],
  );
}

//  SHARED LAYOUT

class _HomeLayout extends StatelessWidget {
  final Widget child;

  const _HomeLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // backgroundColor: Colors.amber,

          elevation: 0,
          pinned: true,
          expandedHeight: 80.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(14, 0, 14, 07),
            // title: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children:[
            title: Text(
              "Home",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),

              // ),
              // GestureDetector(child: Icon(Icons.radio_outlined,size: 20,),),
              // ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

//  SUB HEADER

class _SubHeader extends StatelessWidget {
  final String title;
  const _SubHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14.0, 0, 0, 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
