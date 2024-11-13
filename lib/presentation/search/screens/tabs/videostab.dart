import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class Videostab extends StatelessWidget {
  const Videostab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<VideoBloc, VideoState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is VideosResultState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.searchedVideo.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final songData = state.searchedVideo[index];
                  return SongTitle(songData: songData, songIndex: index);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
