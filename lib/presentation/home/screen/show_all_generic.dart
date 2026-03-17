import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double expandedBarHeight = 110.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            stretch: true,
            expandedHeight: expandedBarHeight,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double top = constraints.biggest.height;
                final double minHeight = kToolbarHeight + statusBarHeight;
                
                // Calculate ratios for animations
                // 1.0 = fully expanded, 0.0 = fully collapsed
                final double expandRatio = ((top - minHeight) / (expandedBarHeight - kToolbarHeight)).clamp(0.0, 1.0);
                final double collapseRatio = 1.0 - expandRatio;

                return Stack(
                  children: [
                    //  STATIC BACK BUTTON (Always visible)
                    Positioned(
                      left: 8,
                      top: statusBarHeight,
                      height: kToolbarHeight,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           const Icon(Icons.arrow_back_ios_new, color: Colors.red, size: 20),
                          const  SizedBox(width: 4),
                            Opacity(
opacity: expandRatio,
                              child: const Text(
                                'Home',
                                style: TextStyle(color: Colors.red, fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SMALL TITLE (Centered in Toolbar - Fades in on collapse)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: statusBarHeight,
                      height: kToolbarHeight,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 40),
                        child: Opacity(
                          // Starts fading in after 80% of the scroll is done
                          opacity: collapseRatio > 0.8 ? (collapseRatio - 0.8) / 0.2 : 0.0,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    //  BIG TITLE (Bottom Left - Fades out on collapse)
                    Positioned(
                      left: 20,
                      bottom: 12,
                      child: Opacity(
                        opacity: expandRatio,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 28,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // CONTENT SECTION
          items.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => HomePlaylist(playList: items[index]),
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
          Icon(Icons.music_note_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            "Nothing here",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'serif'
            ),
          ),
        ],
      ),
    );
  }
}