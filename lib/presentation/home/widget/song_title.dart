import 'package:flutter/material.dart';

import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

class SongTitle extends StatelessWidget {
  final Songmodel songData;
  final int songIndex;

  const SongTitle({
    super.key,
    required this.songData,
    required this.songIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Container(
      margin: EdgeInsets.all(screenSize * 0.00395),
      child: ListTile(
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context)
              .pushNamed(AudioPlayerScreen.routeName, arguments: {
            "songindex": songIndex,
            "songdata": songData,
            "route": SongMiniPlayerRoute.songRoute
          });
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0106),
          child: cacheImage(
            imageUrl: songData.thumbnail,
            width: screenSize * 0.0755,
            height: screenSize * 0.0733,
          ),
        ),
        title: Text(
          songData.songName,
          style: Theme.of(context).textTheme.titleSmall!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          songData.artist.name,
          style: Theme.of(context).textTheme.bodySmall!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: songData.duration.isNotEmpty ? Text(songData.duration) : null,
      ),
    );
  }
}
