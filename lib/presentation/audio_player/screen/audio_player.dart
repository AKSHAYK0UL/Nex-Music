import 'package:flutter/material.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/player.dart';

class AudioPlayerScreen extends StatefulWidget {
  static const routeName = "/audioplayer";
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  // late String songUrl;
  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final songData = ModalRoute.of(context)?.settings.arguments as Songmodel;
  //     final songId = songData.vId;
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final songData = ModalRoute.of(context)?.settings.arguments as Songmodel;

    return Scaffold(
      body: Column(
        children: [
          Image.network(songData.thumbnail),
          Player(songId: songData.vId),
        ],
      ),
    );
  }
}
