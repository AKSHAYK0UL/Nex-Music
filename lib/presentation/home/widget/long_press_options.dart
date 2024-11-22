import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/songmodel.dart';

Future<void> showLongPressOptions(
    {required BuildContext context,
    required Songmodel songData,
    required double screenSize}) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: ListTile(
          tileColor: backgroundColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: screenSize * 0.0050, vertical: screenSize * 0.00005),
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
            style: Theme.of(context).textTheme.titleMedium!,
          ),
          subtitle: animatedText(
            text: songData.artist.name,
            style: Theme.of(context).textTheme.bodySmall!,
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                context
                    .read<SongstreamBloc>()
                    .add(AddToPlayNextEvent(songData: songData));
                Navigator.of(context).pop();
              },
              label: Text(
                "Play Next",
                style: Theme.of(context).textTheme.labelMedium!,
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                overlayColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.play_arrow,
                color: textColor,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              label: Text(
                "Add to Playlist",
                style: Theme.of(context).textTheme.labelMedium!,
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                overlayColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.playlist_add,
                color: textColor,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              label: animatedText(
                  text: "View Artist (${songData.artist.name})",
                  style: Theme.of(context).textTheme.labelMedium!),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                overlayColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.person,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    },
  );
}
