import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/widget/playlistgridview.dart';

class ArtistAlbum extends StatefulWidget {
  final ArtistModel artist;

  const ArtistAlbum({required this.artist, super.key});

  @override
  State<ArtistAlbum> createState() => _ArtistAlbumState();
}

class _ArtistAlbumState extends State<ArtistAlbum> {
  @override
  void initState() {
    final currentState = context.read<FullArtistAlbumBloc>().state;
    if (currentState.runtimeType != FullartistalbumDataState) {
      context
          .read<FullArtistAlbumBloc>()
          .add(GetArtistAlbumsEvent(artist: widget.artist));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return BlocBuilder<FullArtistAlbumBloc, FullArtistAlbumState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is FullartistalbumDataState) {
          return SingleChildScrollView(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: screenSize * 0.00107,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.artistAlbums.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistData = state.artistAlbums[index];
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
