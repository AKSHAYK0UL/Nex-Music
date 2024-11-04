import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';

class PlaylistView extends StatelessWidget {
  final PlayListmodel playList;
  const PlaylistView({
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
      child: Container(
        // width: 226,
        width: screenSize * 0.298,
        margin: EdgeInsets.all(screenSize * 0.0106),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: playList.thumbnail,
                height: screenSize * 0.298,
                fit: BoxFit.fill,
                placeholder: (_, __) {
                  return Image.asset(
                    "assets/imageplaceholder.png",
                    height: screenSize * 0.298,
                    fit: BoxFit.fill,
                  );
                },
                errorWidget: (_, __, ___) => Image.asset(
                  "assets/imageplaceholder.png",
                  height: screenSize * 0.298,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: screenSize * 0.0158,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0200),
                child: animatedText(
                  text: playList.playlistName,
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
              // Text(
              //   nameShotener(name: playList.playlistName, length: 16),
              //   maxLines: 1,
              //   style: Theme.of(context).textTheme.titleMedium,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
