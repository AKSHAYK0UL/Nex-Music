import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/ui_component/collapsing_title_sliver_app_bar.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';

class ShowAllGeneric extends StatelessWidget {
  final String title;
  final List<PlayListmodel> items;
  final bool isAlbum;

  const ShowAllGeneric({
    super.key,
    required this.title,
    required this.items,
    this.isAlbum = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CollapsingTitleSliverAppBar(
            title: title,
            backLabel: 'Home',
            onBackTap: () => context.pop(),
            bigTitleFontSize: 28.0,
          ),

          // CONTENT SECTION
          items.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => HomePlaylist(
                        playList: items[index],
                        isAlbum: isAlbum,
                      ),
                      childCount: items.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded,
              size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            "Nothing here",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          ),
        ],
      ),
    );
  }
}
