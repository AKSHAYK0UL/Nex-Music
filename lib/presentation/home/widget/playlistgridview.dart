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
            horizontal: screenSize * 0.0050, vertical: screenSize * 0.0050),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              Expanded(
                child: GridTile(
                  footer: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenSize * 0.0110),
                    color: Colors.black54,
                    alignment: Alignment.center,
                    height: screenSize * 0.0431,
                    child: animatedText(
                      text: playList.playlistName,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  child: cacheImage(
                    imageUrl: playList.thumbnail,
                    height: 0,
                    width: double.infinity,
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
