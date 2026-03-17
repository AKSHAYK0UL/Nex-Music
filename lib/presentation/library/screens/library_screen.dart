

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
              child: Text(
                'Library',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // The List Options
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Playlists
                  LibraryTile(
                    icon: CupertinoIcons.music_note_list,
                    title: "Playlists",
                    onTap: () {
                      context.pushNamed(RouterName.libraryUserPlaylistName);
                    },
                  ),
                  // Artists
                  LibraryTile(
                    icon: CupertinoIcons.person,
                    title: "Artists",
                    onTap: () {
                      context.pushNamed(RouterName.savedArtistName);
                    },
                  ),
                  // Albums
                  LibraryTile(
                    icon: CupertinoIcons.square_stack,
                    title: "Albums",
                    onTap: () {
                      // Add Albums navigation here
                    },
                  ),
                  // Favorites
                  LibraryTile(
                    icon: CupertinoIcons.heart,
                    title: "Favorites",
                    onTap: () {
                      context.pushNamed(RouterName.favoritesSongsName);
                    },
                  ),
                  // Downloads
                  LibraryTile(
                    icon: CupertinoIcons.cloud_download,
                    title: "Downloads",
                    onTap: () {
                      context.pushNamed(RouterName.downloadedSongsName);
                    },
                  ),
                  // Podcasts
                  LibraryTile(
                    icon: CupertinoIcons.antenna_radiowaves_left_right,
                    title: "Podcasts",
                    onTap: () {
                      // Add Podcasts navigation here
                      context.pushNamed(RouterName.podcastsName);
                    },
                  ),
                  //Audio books
                  LibraryTile(
                    icon: CupertinoIcons.book,
                    title: "Audiobooks",
                    onTap: () {
                      // Add Audio books navigation here
                      context.pushNamed(RouterName.audioBooksName);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Tile Widget
class LibraryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const LibraryTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.white,
        height: 56,
        padding: const EdgeInsets.only(left: 20),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Section
              SizedBox(
                width: 30,
                child: Icon(
                  icon,
                  color: const Color(0xFFFF2D55),
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),

              // Text and Divider Section
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E5EA),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: Color(0xFFC7C7CC),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
