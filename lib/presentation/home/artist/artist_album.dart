import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';

class ArtistAlbum extends StatelessWidget {
  final ArtistModel artist;

  const ArtistAlbum({required this.artist, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullArtistAlbumBloc, FullArtistAlbumState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is FullartistalbumDataState) {
          return state.artistAlbums.isEmpty
              ? Center(
                  child: Text(
                    "No albums found.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: state.artistAlbums.length,
                  itemBuilder: (BuildContext context, int index) {
                    final playlistData = state.artistAlbums[index];
                    return HomePlaylist(
                      playList: playlistData,
                    );
                  },
                );
        }
        return const SizedBox();
      },
    );
  }
}
