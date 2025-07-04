import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';

class PlaylistGridView extends StatelessWidget {
  final PlayListmodel playList;
  const PlaylistGridView({
    super.key,
    required this.playList,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ShowPlaylist.routeName, arguments: playList);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize * 0.0095,
          vertical: screenSize * 0.0065,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GridTile(
            footer: Container(
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0110),
              color: Colors.black54,
              alignment: Alignment.center,
              height: screenSize * 0.0431,
              child: animatedText(
                text: playList.playlistName,
                style: Theme.of(context).textTheme.titleMedium!,
              ),
            ),
            child: Hero(
              tag: playList.playListId,
              child: cacheImage(
                imageUrl: playList.thumbnail,
                height: 0,
                width: double.infinity,
                isRecommendedPlaylist: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
