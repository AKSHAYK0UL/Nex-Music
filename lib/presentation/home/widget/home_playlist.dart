
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';

class HomePlaylist extends StatelessWidget {
  final PlayListmodel playList;
  
  const HomePlaylist({
    super.key,
    required this.playList,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(RouterPath.showPlaylistSongsRoute, extra: playList);
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //  The Artwork (Square, Rounded Corners)
          AspectRatio(
            aspectRatio: 1.0, 
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: playList.playListId,
                  child: cacheImage(
                    imageUrl: playList.thumbnail,
                    width: double.infinity, 
                    height: double.infinity,
                    isRecommendedPlaylist: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // The Title (SF Pro style bold)
          Flexible(
            child: Text(
              playList.playlistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          // The Subtitle (Grey, smaller)
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              playList.artistBasic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}