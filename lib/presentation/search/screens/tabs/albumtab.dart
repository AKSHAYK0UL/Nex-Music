import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/home/widget/playlistgridview.dart';

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
    final currentState = context.read<SearchAlbumBloc>().state;
    if (currentState.runtimeType != SearchedAlbumsDataState) {
      context
          .read<SearchAlbumBloc>()
          .add(SearchAlbumsEvent(inputText: widget.inputText));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchAlbumBloc, SearchAlbumState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is SearchedAlbumsDataState) {
          return SingleChildScrollView(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: widget.screenSize * 0.00107,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.albums.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistData = state.albums[index];
                return PlaylistGridView(
                  playList: playlistData,
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
