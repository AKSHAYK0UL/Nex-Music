
import 'package:flutter/material.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/build_playlist_album_card.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

// Original SongColumView with 3 songs in one column
class SongColumView extends StatelessWidget {
  final int rowIndex;
  final int quickPicksLength;
  final List<Songmodel> quickPicks;
  const SongColumView({
    required this.rowIndex,
    required this.quickPicksLength,
    required this.quickPicks,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: screenSize * 0.43,
      child: Column(
        children: List.generate(
          3, // Changed from 4 to 3
          (columnIndex) {
            final index =
                rowIndex * 3 + columnIndex; // Calculate the actual index (changed from 4 to 3)
            if (index < quickPicksLength) {
              final songData = quickPicks[index];
              return SizedBox(
                child: RecentSongTile(
                  showDelete: false,
                  songData: songData,
                  songIndex: index,
                  tabRouteENUM: TabRouteENUM.other,
                ),
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

// Updated FeaturedCarousel using PageView with SongColumView
class FeaturedCarousel extends StatelessWidget {
  final List<Songmodel> songs;

  const FeaturedCarousel({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    
    // Safety check for empty songs list
    if (songs.isEmpty) {
      return SizedBox(
        height: screenSize.height * 0.460,
        child: const Center(
          child: Text(
            'No songs available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: screenSize.height * 0.370, // Same height as original
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92), // Peeking effect
        padEnds: false,
        itemCount: (songs.length / 3).ceil(), // Calculate the number of horizontal items (changed from 4 to 3)
        itemBuilder: (context, rowIndex) {
          // final double leftPadding = rowIndex == 0 ? 20.0 : 8.0;
          //  final double rightPadding = rowIndex == (songs.length / 3).ceil() - 1 ? 20.0 : 0.0;

          return SongColumView(
              rowIndex: rowIndex,
              quickPicksLength: songs.length,
              quickPicks: songs,
            
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
      height: screenSize.height * 0.38,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          
          // final double leftPadding = index == 0 ? 20.0 : 8.0;
           final double rightPadding = index == itemCount - 1 ? 14.0 : 0.0;

          return Padding(
            padding: EdgeInsets.only(left: 14, right: rightPadding),
            child: BuildPlaylistAlbumCard(isAlbum: false,playlist: playlist,screenSize:screenSize ),
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
      height: screenSize.height * 0.38,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final album = albums[index];
          
          // final double leftPadding = index == 0 ? 20.0 : 8.0;
          final double rightPadding = index == itemCount - 1 ? 14.0 : 0.0;

          return Padding(
            padding: EdgeInsets.only(left: 14, right: rightPadding),
            child: BuildPlaylistAlbumCard(isAlbum: true,playlist: album,screenSize:screenSize ),
          );
        },
      ),
    );
  }
}
