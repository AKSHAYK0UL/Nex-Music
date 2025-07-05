import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/playlist/screen/playlist_loading.dart';

class HomePlaylist extends StatelessWidget {
  final PlayListmodel playList;
  const HomePlaylist({
    super.key,
    required this.playList,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () {
        // Navigator.of(context)
        //     .pushNamed(ShowPlaylist.routeName, arguments: playList);
        Navigator.of(context)
            .pushNamed(PlaylistLoading.routeName, arguments: playList);
      },
      child: Container(
        width: screenSize * 0.288,
        margin: EdgeInsets.all(screenSize * 0.0106),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          child: Hero(
            tag: playList.playListId,
            child: cacheImage(
              imageUrl: playList.thumbnail,
              width: screenSize * 0.288,
              height: screenSize * 0.345,
              isRecommendedPlaylist: true,
            ),
          ),
        ),
      ),
    );
  }
}
