import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';
import 'package:nex_music/presentation/audio_player/widget/streambuilder.dart';

// ignore: must_be_immutable
class AudioPlayerScreen extends StatelessWidget {
  static const routeName = "/audioplayer";
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final routeData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final songData = routeData["songdata"] as Songmodel;
    final route = routeData["route"] as SongMiniPlayerRoute;

    return Scaffold(
      body: SafeArea(
        // minimum: EdgeInsets.only(top: screenSize * 0.0659),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize * 0.0197,
                  vertical: screenSize * 0.00725),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: textColor,
                      size: screenSize * 0.0493,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
                  child: Center(
                    child: Hero(
                      tag: songData.vId,
                      child: Container(
                        height: screenSize * 0.410,
                        width: screenSize * 0.448,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenSize * 0.0131),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenSize * 0.0131),
                          child: cacheImage(
                            imageUrl: songData.thumbnail,
                            width: screenSize * 0.448,
                            height: screenSize * 0.410,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenSize * 0.0380,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenSize * 0.356,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                animatedText(
                                  text: songData.songName,
                                  style:
                                      Theme.of(context).textTheme.titleLarge!,
                                ),
                                SizedBox(
                                  height: screenSize * 0.0050,
                                ),
                                animatedText(
                                  text: songData.artist.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              CupertinoIcons.heart_fill,
                              color: textColor,
                              size: screenSize * 0.0395,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: screenSize * 0.0370,
                ),
                StreamBuilderWidget(
                  songData: songData,
                  screenSize: screenSize,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.shuffle,
                          color: textColor,
                          size: screenSize * 0.0350, //329
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.skip_previous,
                          color: textColor,
                          size: screenSize * 0.0527,
                        ),
                      ),
                      Player(
                        songData: songData,
                        screenSize: screenSize,
                        route: route,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.skip_next,
                          color: textColor,
                          size: screenSize * 0.0527,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.loop,
                          color: textColor,
                          size: screenSize * 0.0350,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenSize * 0.0240,
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      color: textColor,
                      size: screenSize * 0.0593,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
