import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';

// ignore: must_be_immutable
class AudioPlayerScreen extends StatelessWidget {
  static const routeName = "/audioplayer";
  AudioPlayerScreen({super.key});

  double sliderValue = 0.0;

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
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5.5),
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
                        height: screenSize * 0.420,
                        width: screenSize * 0.448,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenSize * 0.0131),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenSize * 0.0131),
                          child: CachedNetworkImage(
                            imageUrl: songData.thumbnail,
                            height: screenSize * 0.420,
                            width: screenSize * 0.448,
                            fit: BoxFit.fill,
                            placeholder: (_, __) => Image.asset(
                              "assets/imageplaceholder.png",
                              height: screenSize * 0.420,
                              width: screenSize * 0.448,
                              fit: BoxFit.fill,
                            ),
                            errorWidget: (_, __, ___) => Image.asset(
                              "assets/imageplaceholder.png",
                              height: screenSize * 0.420,
                              width: screenSize * 0.448,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenSize * 0.0395,
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
                              Icons.favorite,
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
                  height: screenSize * 0.0395,
                ),
                StreamBuilder(
                  stream: context.read<SongstreamBloc>().songPosition,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    final duration =
                        context.read<SongstreamBloc>().songDuration;
                    final position = snapshot.data;

                    double sliderValue = 0.0;
                    if (position != null && duration.inMilliseconds > 0) {
                      sliderValue =
                          position.inMilliseconds / duration.inMilliseconds;
                    }

                    return Column(
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) => Slider(
                            value: sliderValue,
                            min: 0,
                            max: 1,
                            onChanged: (value) {
                              setState(() {
                                sliderValue = value;
                              });
                            },
                            onChangeEnd: (value) {
                              final seekToPosition = Duration(
                                milliseconds:
                                    (value * duration.inMilliseconds).toInt(),
                              );
                              context
                                  .read<SongstreamBloc>()
                                  .add(SeekToEvent(position: seekToPosition));
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize * 0.0329),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(timeFormate(position!.inSeconds)),
                              Text(songData.duration),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                          Icons.shuffle,
                          color: textColor,
                          size: screenSize * 0.0329,
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
                          Icons.loop_sharp,
                          color: textColor,
                          size: screenSize * 0.0329,
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
