import 'package:flutter/material.dart';

import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

class SongTitle extends StatelessWidget {
  final Songmodel songData;

  const SongTitle({
    super.key,
    required this.songData,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Container(
      margin: EdgeInsets.all(screenSize * 0.00395),
      child: ListTile(
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pushNamed(AudioPlayerScreen.routeName,
              arguments: {
                "songdata": songData,
                "route": SongMiniPlayerRoute.songRoute
              });
        },
        leading: Hero(
          tag: songData.vId,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenSize * 0.0106),
            child: cacheImage(
              imageUrl: songData.thumbnail,
              width: screenSize * 0.0755,
              height: screenSize * 0.0733,
            ),
          ),
        ),
        title: animatedText(
          text: songData.songName,
          style: Theme.of(context).textTheme.titleSmall!,
        ),
        subtitle: animatedText(
          text: songData.artist.name,
          style: Theme.of(context).textTheme.bodySmall!,
        ),
        trailing: songData.duration.isNotEmpty ? Text(songData.duration) : null,
      ),
    );
  }
}
