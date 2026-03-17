import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';

class AlbumTab extends StatefulWidget {
  final String inputText;
  final double screenSize;

  const AlbumTab({
    super.key,
    required this.inputText,
    required this.screenSize,
  });

  @override
  State<AlbumTab> createState() => AlbumTabState();
}

class AlbumTabState extends State<AlbumTab> {
  @override
  void initState() {
    super.initState();
    // Only trigger search if don't already have results for this search
    final currentState = context.read<SearchAlbumBloc>().state;
    if (currentState.runtimeType != SearchedAlbumsDataState) {
      context.read<SearchAlbumBloc>().add(SearchAlbumsEvent(inputText: widget.inputText));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchAlbumBloc, SearchAlbumState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) return loadingDisk();
        if (state is SearchedAlbumsDataState) {
          if (state.albums.isEmpty) return _buildEmptyState("No albums found");

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              childAspectRatio: 0.78, 
            ),
            itemCount: state.albums.length,
            itemBuilder: (context, index) {
              // return PlaylistGridView(playList: state.albums[index]);
              return HomePlaylist(playList: state.albums[index]);
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