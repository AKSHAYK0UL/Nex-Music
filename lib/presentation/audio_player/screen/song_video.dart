import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:splayer/splayer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SongVideo extends StatefulWidget {
  static const routeName = "/songvideo";
  const SongVideo({super.key});

  @override
  State<SongVideo> createState() => _SongVideoState();
}

class _SongVideoState extends State<SongVideo> {
  late PodPlayerController controller;

  late Songmodel songData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songData = ModalRoute.of(context)?.settings.arguments as Songmodel;

    controller = PodPlayerController(
        podPlayerConfig: const PodPlayerConfig(
            isLive: false,
            autoPlay: true,
            tap: true,
            videoQualityPriority: [
              1080,
              720,
              480,
              360,
            ]),
        playVideoFrom: PlayVideoFrom.youtube(songData.vId, live: false))
      ..initialise();
    controller.enableFullScreen();
    controller.play();

    // _controller = YoutubePlayerController(
    //   params: const YoutubePlayerParams(
    //     mute: false,
    //     showControls: true,
    //     showFullscreenButton: true,
    //   ),
    // );

    // _controller.loadVideoById(videoId: songData.vId); // Auto Play
    // _controller.enterFullScreen();
    // final isFullScreen = _controller.value.fullScreenOption.enabled;
    // print("ISFULL SCREEN $isFullScreen @@@@@@@@");

    //   final videoId = YoutubePlayer.convertUrlToId(songData.vId) ?? "";

    //   _controller = YoutubePlayerController(
    //     initialVideoId: videoId,
    //     flags: const YoutubePlayerFlags(
    //       showLiveFullscreenButton: false,
    //       autoPlay: true,
    //       mute: false,
    //       enableCaption: true,
    //       forceHD: true,
    //     ),
    //   );
    //   _controller.toggleFullScreenMode();
  }

  // @override
  // void dispose() {
  //   _restoreSystemUI();
  //   _controller.close();
  //   super.dispose();
  // }

  // void _restoreSystemUI() {
  //   // Restore system navigation and status bars
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   // Restore to portrait mode
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // }

  // void _handlePop() {
  //   _controller.pauseVideo();
  //   _restoreSystemUI();
  //   Navigator.of(context)
  //       .popUntil(ModalRoute.withName(AudioPlayerScreen.routeName));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PodVideoPlayer(
        videoAspectRatio: 16 / 9,
        controller: controller,
        isLive: false,
        frameAspectRatio: 16 / 9,
        videoTitle: const Text('Demo Video'),
      ),
    );
    // return PopScope(
    //   onPopInvokedWithResult: (_, __) {
    //     // _handlePop();
    //   },
    //   child: YoutubePlayerScaffold(
    //     controller: _controller,
    //     autoFullScreen: true,
    //     aspectRatio: 16 / 9,
    //     builder: (context, player) {
    //       return Scaffold(
    //         appBar: AppBar(
    //           title: Text(
    //             "Video",
    //             style: Theme.of(context).textTheme.titleLarge!,
    //           ),
    //         ),
    //         body: Center(child: player),
    //       );
    //     },
    //   ),
    // );
  }
}
