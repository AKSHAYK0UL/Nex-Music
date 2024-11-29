import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class ArtistScreen extends StatefulWidget {
  final ArtistModel artist;
  const ArtistScreen({required this.artist, super.key});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  void initState() {
    final currentState = context.read<FullArtistSongBloc>().state;
    if (currentState.runtimeType != ArtistSongsState) {
      context
          .read<FullArtistSongBloc>()
          .add(GetArtistSongsEvent(artistId: widget.artist.artist.artistId!));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return BlocBuilder<FullArtistSongBloc, FullArtistSongState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingStata) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state is ArtistSongsState) {
          return ListView.builder(
            itemCount: state.artistSongs.length,
            itemBuilder: (context, index) {
              final songData = state.artistSongs[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0131),
                child: SongTitle(
                  songData: songData,
                  songIndex: index,
                  showDelete: false,
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
