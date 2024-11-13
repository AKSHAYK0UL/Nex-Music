import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';

import 'package:nex_music/presentation/home/widget/song_title.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongBloc, SongState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is SongsResultState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.searchedSongs.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final songData = state.searchedSongs[index];
                return SongTitle(songData: songData, songIndex: index);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
