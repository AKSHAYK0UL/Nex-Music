import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';

class PlaylistLoading extends StatelessWidget {
  final PlayListmodel playlistData;

  const PlaylistLoading({super.key, required this.playlistData});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistData.playlistName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 27,
        children: [
          Center(
            child: Hero(
              tag: playlistData.playListId,
              child: SizedBox(
                height: screenHeight * 0.527,
                width: screenWidth * 0.892,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: cacheImage(
                    imageUrl: playlistData.thumbnail,
                    width: 0,
                    height: 0,
                    isRecommendedPlaylist: true,
                  ),
                ),
              ),
            ),
          ),
          Transform.scale(
            scaleX: screenWidth * 0.00392,
            child: Center(
              child: Lottie.asset(
                reverse: true,
                fit: BoxFit.fill,
                "assets/loadingmore.json",
                width: double.infinity,
                height: screenHeight * 0.0197,
              ),
            ),
          )
        ],
      ),
    );
  }
}
