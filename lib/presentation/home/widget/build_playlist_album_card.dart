import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';

class BuildPlaylistAlbumCard extends StatelessWidget {
  final PlayListmodel playlist;
  final Size screenSize;
  final bool isAlbum;

  const BuildPlaylistAlbumCard({
    super.key,
    required this.playlist,
    required this.isAlbum,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          RouterPath.showPlaylistSongsRoute,
          extra: {
            'playlistData': playlist,
            'isAlbum': isAlbum,
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category/Eyebrow Text
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              isAlbum ? "ALBUMS" : "PLAYLIST",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Main Title
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              playlist.playlistName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Big Image Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Hero(
                      tag: playlist.playListId,
                      child: cacheImage(
                        imageUrl: playlist.thumbnail,
                        width: double.infinity,
                        height: double.infinity,
                        islocal: false,
                      ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6)
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom Left Overlay Text (Artist Name)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Text(
                        playlist.artistBasic.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
