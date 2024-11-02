import 'package:flutter/material.dart';
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
        onTap: () {
          Navigator.of(context)
              .pushNamed(AudioPlayerScreen.routeName, arguments: songData);
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0106),
          child: Image.network(songData.thumbnail),
        ),
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
      ),
    );
  }
}
