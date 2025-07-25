import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';

class ShowAllPlaylists extends StatelessWidget {
  static const routeName = "/showallplaylists";
  const ShowAllPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommended playlists"),
      ),
      body: BlocBuilder<HomesectionBloc, HomesectionState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is LoadingState) {
            return const Loading();
          }
          if (state is ErrorState) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          if (state is HomeSectionState) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: screenSize * 0.00109,
              ),
              itemCount: state.playlist.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistData = state.playlist[index];
                return HomePlaylist(
                  playList: playlistData,
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: MiniPlayer(screenSize: screenSize),
    );
  }
}
