import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/presentation/home/widget/playlistgridview.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Center(
      child: BlocBuilder<SearchedplaylistBloc, SearchedplaylistState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is PlaylistDataState) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: screenSize * 0.00107,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.playlist.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistData = state.playlist[index];
                return PlaylistGridView(
                  playList: playlistData,
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
