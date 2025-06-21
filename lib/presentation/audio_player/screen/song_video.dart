import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongVideo extends StatefulWidget {
  static const routeName = "/songvideo";
  const SongVideo({super.key});

  @override
  State<SongVideo> createState() => _SongVideoState();
}

class _SongVideoState extends State<SongVideo> {
  late YoutubePlayerController _controller;
  late Songmodel songData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songData = ModalRoute.of(context)?.settings.arguments as Songmodel;

    final videoId = YoutubePlayer.convertUrlToId(songData.vId) ?? "";

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        showLiveFullscreenButton: false,
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: true,
      ),
    );
    _controller.toggleFullScreenMode();
  }

  @override
  void dispose() {
    _restoreSystemUI();
    _controller.dispose();
    super.dispose();
  }

  void _restoreSystemUI() {
    // Restore system navigation and status bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Restore to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _handlePop() {
    _controller.pause();
    _restoreSystemUI();
    Navigator.of(context)
        .popUntil(ModalRoute.withName(AudioPlayerScreen.routeName));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _handlePop();
      },
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Video",
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
            body: Center(child: player),
          );
        },
      ),
    );
  }
}
