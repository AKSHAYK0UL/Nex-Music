import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';

class MiniPlayer extends StatelessWidget {
  final double screenSize;

  const MiniPlayer({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongstreamBloc, SongstreamState>(
      builder: (context, state) {
        if (state is PlayingState || state is PausedState) {
          Songmodel? songData;

          // Handle PlayingState
          if (state is PlayingState) {
            songData = state.songData;
          }

          // Handle PausedState
          if (state is PausedState) {
            songData = state.songData;
          }

          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AudioPlayerScreen.routeName,
                  arguments: {
                    "songdata": songData,
                    "route": SongMiniPlayerRoute.miniPlayerRoute
                  });
            },
            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(vertical: screenSize * 0.015),
              color: Colors.black.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenSize * 0.035,
                        backgroundImage: NetworkImage(songData!
                            .thumbnail), // Assuming the songUrl is an image URL
                      ),
                      SizedBox(width: screenSize * 0.015),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songData.songName,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            songData.artist.name,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      state is PlayingState ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.read<SongstreamBloc>().add(PlayPauseEvent());
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
