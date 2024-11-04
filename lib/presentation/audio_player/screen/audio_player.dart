import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';

class AudioPlayerScreen extends StatefulWidget {
  static const routeName = "/audioplayer";
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  double sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final songData = ModalRoute.of(context)?.settings.arguments as Songmodel;

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(top: screenSize * 0.0659),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0329),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: screenSize * 0.448,
                  width: screenSize * 0.448,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenSize * 0.0131),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenSize * 0.0131),
                    child: CachedNetworkImage(
                      imageUrl: songData.thumbnail,
                      height: screenSize * 0.448,
                      width: screenSize * 0.448,
                      fit: BoxFit.fill,
                      placeholder: (_, __) => Image.asset(
                        "assets/imageplaceholder.png",
                        height: screenSize * 0.448,
                        width: screenSize * 0.448,
                        fit: BoxFit.fill,
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        "assets/imageplaceholder.png",
                        height: screenSize * 0.448,
                        width: screenSize * 0.448,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenSize * 0.0395,
              ),
              Row(
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
                              style: Theme.of(context).textTheme.titleLarge!,
                            ),
                            SizedBox(
                              height: screenSize * 0.0050,
                            ),
                            animatedText(
                              text: songData.artist.name,
                              style: Theme.of(context).textTheme.titleMedium!,
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
              SizedBox(
                height: screenSize * 0.0395,
              ),
              Transform.scale(
                scaleX: screenSize * 0.00155,
                child: Slider(
                  value: sliderValue,
                  onChanged: (value) {
                    setState(
                      () {
                        final formated = value.toStringAsFixed(2);
                        sliderValue = double.parse(formated);
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("0:00"),
                  Text(sliderValue.toString()),
                ],
              ),
              Row(
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
                    songId: songData.vId,
                    screenSize: screenSize,
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
              SizedBox(
                height: screenSize * 0.0250,
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
        ),
      ),
    );
  }
}
