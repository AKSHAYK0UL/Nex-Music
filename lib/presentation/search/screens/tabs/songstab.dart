import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class SongsTab extends StatelessWidget {
  final String inputText;
  final double screenSize;
  const SongsTab({
    super.key,
    required this.inputText,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongBloc, SongState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is SongsResultState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  right: screenSize * 0.0131,
                  left: screenSize * 0.0131,
                  top: screenSize * 0.0131),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.searchedSongs.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final songData = state.searchedSongs[index];
                  return SongTitle(
                    songData: songData,
                    songIndex: index,
                    showDelete: false,
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
