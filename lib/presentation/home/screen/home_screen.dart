

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/loading.dart';
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
            backgroundColor: Colors.white,
            body: _HomeLayout(
              child: _buildBody( context,state),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

//  BODY 

Widget _buildBody(BuildContext context,HomeSectionStateData state, ) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          const _SubHeader(title: "Top Picks For You"),
          FeaturedCarousel(songs: state.quickPicks),

          // const SizedBox(height: 5),

          // Made For You Playlists
          SectionHeader(
            title: "Made For You",
            // onTap: () => context.push(RouterPath.showAllPlaylistsRoute),
            onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Made For You',
                  'items': state.playlist,
                  'isAlbum': false,
                },
              ),
          ),
          PlaylistCarousel(
            playlists: state.playlist.take(7).toList(),
          ),

          const SizedBox(height: 35),

          // New Albums
          SectionHeader(
            title: "New Albums",
            // onTap: () => context.push(RouterPath.showAllAlbumsRoute),
            onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'New Albums',
                  'items': state.albums,
                  'isAlbum': true,
                },
              ),
          ),
          AlbumCarousel(
            albums: state.albums.take(7).toList(),
          ),

          const SizedBox(height: 35),

          // Global Hits
          if (state.globalHitsPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Global Hits",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Global Hits',
                  'items': state.globalHitsPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.globalHitsPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Globally
          if (state.trendingGloballyPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Globally",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Globally',
                  'items': state.trendingGloballyPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingGloballyPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Punjabi Playlists
          if (state.trendingPunjabiPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Punjabi Playlists",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Punjabi Playlists',
                  'items': state.trendingPunjabiPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingPunjabiPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Punjabi Albums
          if (state.trendingPunjabiAlbums.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Punjabi Albums",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Punjabi Albums',
                  'items': state.trendingPunjabiAlbums,
                  'isAlbum': true,
                },
              ),
            ),
            AlbumCarousel(
              albums: state.trendingPunjabiAlbums.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Hindi Playlists
          if (state.trendingHindiPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Hindi Playlists",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Hindi Playlists',
                  'items': state.trendingHindiPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingHindiPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Hindi Albums
          if (state.trendingHindiAlbums.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Hindi Albums",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Hindi Albums',
                  'items': state.trendingHindiAlbums,
                  'isAlbum': true,
                },
              ),
            ),
            AlbumCarousel(
              albums: state.trendingHindiAlbums.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending English Playlists
          if (state.trendingEnglishPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Trending English Playlists",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending English Playlists',
                  'items': state.trendingEnglishPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingEnglishPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Phonk Playlists
          if (state.trendingPhonkPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Phonk Playlists",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Phonk Playlists',
                  'items': state.trendingPhonkPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingPhonkPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Phonk Albums
          if (state.trendingPhonkAlbums.isNotEmpty) ...[
            SectionHeader(
              title: "Trending Phonk Albums",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Trending Phonk Albums',
                  'items': state.trendingPhonkAlbums,
                  'isAlbum': true,
                },
              ),
            ),
            AlbumCarousel(
              albums: state.trendingPhonkAlbums.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Brazilian Phonk Playlists
          if (state.trendingBrazilianPhonkPlaylists.isNotEmpty) ...[
            SectionHeader(
              title: "Brazilian Phonk Playlists",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Brazilian Phonk Playlists',
                  'items': state.trendingBrazilianPhonkPlaylists,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.trendingBrazilianPhonkPlaylists.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Trending Brazilian Phonk Albums
          if (state.trendingBrazilianPhonkAlbums.isNotEmpty) ...[
            SectionHeader(
              title: "Brazilian Phonk Albums",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Brazilian Phonk Albums',
                  'items': state.trendingBrazilianPhonkAlbums,
                  'isAlbum': true,
                },
              ),
            ),
            AlbumCarousel(
              albums: state.trendingBrazilianPhonkAlbums.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Nonstop Punjabi Mashup
          if (state.nonstopPunjabiMashup.isNotEmpty) ...[
            SectionHeader(
              title: "Nonstop Punjabi Mashup",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Nonstop Punjabi Mashup',
                  'items': state.nonstopPunjabiMashup,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.nonstopPunjabiMashup.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Nonstop Hindi Mashup
          if (state.nonstopHindiMashup.isNotEmpty) ...[
            SectionHeader(
              title: "Nonstop Hindi Mashup",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Nonstop Hindi Mashup',
                  'items': state.nonstopHindiMashup,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.nonstopHindiMashup.take(7).toList(),
            ),
            const SizedBox(height: 35),
          ],

          // Nonstop English Mashup
          if (state.nonstopEnglishMashup.isNotEmpty) ...[
            SectionHeader(
              title: "Nonstop English Mashup",
              onTap: () => context.push(
                RouterPath.showAllGenericRoute,
                extra: {
                  'title': 'Nonstop English Mashup',
                  'items': state.nonstopEnglishMashup,
                  'isAlbum': false,
                },
              ),
            ),
            PlaylistCarousel(
              playlists: state.nonstopEnglishMashup.take(7).toList(),
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    ),
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
        const SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          expandedHeight: 80.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.fromLTRB(14, 0, 0, 10),
            title: Text(
              "Home",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
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
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
