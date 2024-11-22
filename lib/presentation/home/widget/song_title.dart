import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';

import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/home/widget/long_press_options.dart';

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
        //TODO: onLongPress show [Play next song, Add to playlist, Show more songs from the same artist]
        onLongPress: () {
          print("Long Press");
          showLongPressOptions(
              context: context, songData: songData, screenSize: screenSize);
        },
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
