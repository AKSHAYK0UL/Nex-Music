import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';

import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';

class PlaylistLoading extends StatefulWidget {
  static const routeName = "/playlist_loading";
  // final PlayListmodel playlistData;

  const PlaylistLoading({super.key});

  @override
  State<PlaylistLoading> createState() => _PlaylistLoadingState();
}

class _PlaylistLoadingState extends State<PlaylistLoading> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistData =
          ModalRoute.of(context)?.settings.arguments as PlayListmodel;

      context
          .read<PlaylistBloc>()
          .add(GetPlaylistEvent(playlistId: playlistData.playListId));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final playlistData =
        ModalRoute.of(context)?.settings.arguments as PlayListmodel;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: animatedText(
          text: playlistData.playlistName,
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      ),
      body: BlocListener<PlaylistBloc, PlaylistState>(
        listener: (context, state) {
          if (state is PlaylistDataState || state is ErrorState) {
            Navigator.of(context).pushReplacementNamed(ShowPlaylist.routeName,
                arguments: playlistData);
          }
        },
        child: Column(
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
      ),
    );
  }
}
