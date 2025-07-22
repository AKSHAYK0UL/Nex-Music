import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_playlist_bloc/bloc/full_artist_playlist_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/widget/playlistgridview.dart';

class ArtistPlaylist extends StatefulWidget {
  final ArtistModel artist;

  const ArtistPlaylist({required this.artist, super.key});

  @override
  State<ArtistPlaylist> createState() => _ArtistPlaylistState();
}

class _ArtistPlaylistState extends State<ArtistPlaylist> {
  @override
  void initState() {
    final currentState = context.read<FullArtistPlaylistBloc>().state;
    if (currentState.runtimeType != FullArtistPlaylistDataState) {
      context.read<FullArtistPlaylistBloc>().add(
          GetFullArtistPlaylistEvent(inputText: widget.artist.artist.name));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return BlocBuilder<FullArtistPlaylistBloc, FullArtistPlaylistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is FullArtistPlaylistDataState) {
          return state.playlistData.isEmpty
              ? Center(
                  child: Text(
                    "No playlists found.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: screenSize * 0.00107,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.playlistData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final playlistData = state.playlistData[index];
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
