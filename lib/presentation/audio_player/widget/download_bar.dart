import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/model/songmodel.dart';

class DownloadBar extends StatelessWidget {
  final Songmodel songData;
  final double downloadPercentage;
  final ThumbnailQuality quality;
  final double screenSize;
  const DownloadBar(
      {super.key,
      required this.songData,
      required this.downloadPercentage,
      required this.quality,
      required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.symmetric(
          horizontal: screenSize * 0.0260, vertical: screenSize * 0.0050),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: BorderSide(color: secondaryColor),
      ),
      elevation: 2,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        contentPadding: EdgeInsets.only(
            left: screenSize * 0.0225, right: screenSize * 0.0100),
        leading: CircleAvatar(
          backgroundColor: secondaryColor,
          radius: 23,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Transform.scale(
              scaleX: quality == ThumbnailQuality.low && !songData.isLocal
                  ? 1
                  : 1.78,
              scaleY: 1.0,
              child: cacheImage(
                  imageUrl: songData.thumbnail,
                  width: screenSize * 0.200,
                  height: screenSize * 0.200),
            ),
          ),
        ),
        title: Text(
          songData.songName,
          style: Theme.of(context).textTheme.displayMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: LinearProgressIndicator(
          value: downloadPercentage / 100,
          backgroundColor: textColor,
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
        trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.close,
              color: boldOrange,
            )),
      ),
    );
  }
}
