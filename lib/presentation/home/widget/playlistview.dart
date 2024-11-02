import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/helper_function/general/nameshotener.dart';

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
                placeholder: (_, __) {
                  return Image.asset(
                    "assets/imageplaceholder.png",
                    height: screenSize * 0.298,
                  );
                },
                errorWidget: (_, __, ___) => Image.asset(
                  "assets/imageplaceholder.png",
                  height: screenSize * 0.298,
                ),
              ),
              SizedBox(
                height: screenSize * 0.0158,
              ),
              Text(
                nameShotener(name: playList.playlistName, length: 16),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
