import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class Videostab extends StatefulWidget {
  final String inputText;
  final double screenSize;

  const Videostab({
    super.key,
    required this.inputText,
    required this.screenSize,
  });

  @override
  State<Videostab> createState() => _VideostabState();
}

class _VideostabState extends State<Videostab> {
  @override
  void initState() {
    final currentState = context.read<VideoBloc>().state;
    if (currentState.runtimeType != VideosResultState) {
      context
          .read<VideoBloc>()
          .add(SearchInVideoEvent(inputText: widget.inputText));
    }

    super.initState();
  }

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
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    right: widget.screenSize * 0.0131,
                    left: widget.screenSize * 0.0131,
                    top: widget.screenSize * 0.0131),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.searchedVideo.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final songData = state.searchedVideo[index];
                    return SongTitle(songData: songData, songIndex: index);
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
