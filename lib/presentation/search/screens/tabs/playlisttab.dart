import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';
import 'package:nex_music/presentation/home/widget/playlistgridview.dart';

class PlaylistTab extends StatefulWidget {
  final String inputText;
  final double screenSize;

  const PlaylistTab({
    super.key,
    required this.inputText,
    required this.screenSize,
  });

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  @override
  void initState() {
    super.initState();
    // Only trigger search iff don't already have results for this search
    final currentState = context.read<SearchedplaylistBloc>().state;
    if (currentState.runtimeType != PlaylistDataState) {
      context.read<SearchedplaylistBloc>().add(SearchInPlaylistEvent(inputText: widget.inputText));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchedplaylistBloc, SearchedplaylistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) return loadingDisk();
        if (state is PlaylistDataState) {
          if (state.playlist.isEmpty) return _buildEmptyState("No playlists found");

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: state.playlist.length,
            itemBuilder: (context, index) {
              // return PlaylistGridView(playList: state.playlist[index]);
                            return HomePlaylist(playList: state.playlist[index]);

            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}