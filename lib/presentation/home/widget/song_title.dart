import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
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
          Navigator.of(context)
              .pushNamed(AudioPlayerScreen.routeName, arguments: songData);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0106),
          child: CachedNetworkImage(
            imageUrl: songData.thumbnail,
            height: screenSize * 0.0733,
            width: screenSize * 0.0755,
            fit: BoxFit.fill,
            placeholder: (_, __) => Image.asset(
              "assets/imageplaceholder.png",
              height: screenSize * 0.0733,
              width: screenSize * 0.0755,
              fit: BoxFit.fill,
            ),
            errorWidget: (_, __, ___) => Image.asset(
              "assets/imageplaceholder.png",
              height: screenSize * 0.0733,
              width: screenSize * 0.0755,
              fit: BoxFit.fill,
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
      ),
    );
  }
}

/*
title: Text(
          songData.songName,
          style: Theme.of(context).textTheme.titleSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          songData.artist.name,
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
 */