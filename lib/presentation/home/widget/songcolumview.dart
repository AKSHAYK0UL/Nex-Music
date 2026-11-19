import 'package:flutter/material.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/build_playlist_album_card.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

// Dynamic SongColumView supporting 1, 2, or 3 songs per column
class SongColumView extends StatelessWidget {
  final int rowIndex;
  final int quickPicksLength;
  final List<Songmodel> quickPicks;
  final int rowsPerColumn;

  const SongColumView({
    required this.rowIndex,
    required this.quickPicksLength,
    required this.quickPicks,
    this.rowsPerColumn = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: screenSize * 0.43,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          rowsPerColumn,
          (columnIndex) {
            final index = rowIndex * rowsPerColumn + columnIndex;
            if (index < quickPicksLength) {
              final songData = quickPicks[index];
              return RecentSongTile(
                showDelete: false,
                songData: songData,
                songIndex: index,
                tabRouteENUM: TabRouteENUM.other,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

// Updated FeaturedCarousel using PageView with dynamic height based on available songs
class FeaturedCarousel extends StatelessWidget {
  final List<Songmodel> songs;

  const FeaturedCarousel({super.key, required this.songs});

  static const double tileHeight = 85.0;

  @override
  Widget build(BuildContext context) {
    // Safety check for empty songs list
    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Adaptively adjust height and rows based on actual song count:
    // 1 song  -> 1 row  (85px)
    // 2 songs -> 2 rows (170px)
    // 3 songs -> 3 rows (255px)
    final int rowsPerColumn = songs.length < 3 ? songs.length : 3;
    final double carouselHeight = rowsPerColumn * tileHeight;
    final int pageCount = (songs.length / rowsPerColumn).ceil();

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: pageCount,
        itemBuilder: (context, rowIndex) {
          return SongColumView(
            rowIndex: rowIndex,
            quickPicksLength: songs.length,
            quickPicks: songs,
            rowsPerColumn: rowsPerColumn,
          );
        },
      ),
    );
  }
}

// Playlist Carousel Component
class PlaylistCarousel extends StatelessWidget {
  final List<PlayListmodel> playlists;

  const PlaylistCarousel({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final itemCount = playlists.length > 8 ? 8 : playlists.length;

    return SizedBox(
      height: screenSize.height * 0.35,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          final double rightPadding = index == itemCount - 1 ? 14.0 : 0.0;

          return Padding(
            padding: EdgeInsets.only(left: 14, right: rightPadding),
            child: BuildPlaylistAlbumCard(
              isAlbum: false,
              playlist: playlist,
              screenSize: screenSize,
            ),
          );
        },
      ),
    );
  }
}

// Album Carousel Component
class AlbumCarousel extends StatelessWidget {
  final List<PlayListmodel> albums;

  const AlbumCarousel({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final itemCount = albums.length > 8 ? 8 : albums.length;

    return SizedBox(
      height: screenSize.height * 0.35,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final album = albums[index];
          final double rightPadding = index == itemCount - 1 ? 14.0 : 0.0;

          return Padding(
            padding: EdgeInsets.only(left: 14, right: rightPadding),
            child: BuildPlaylistAlbumCard(
              isAlbum: true,
              playlist: album,
              screenSize: screenSize,
            ),
          );
        },
      ),
    );
  }
}
