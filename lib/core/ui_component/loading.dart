import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(),
      body: loadingDisk(),
      bottomNavigationBar: MiniPlayer(screenSize: screenSize),
    );
  }
}
