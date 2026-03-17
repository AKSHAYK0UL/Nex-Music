import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_video_bloc/bloc/full_artist_video_bloc_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

class ArtistVideos extends StatefulWidget {
  final ArtistModel artist;
  const ArtistVideos({required this.artist, super.key});
  @override
  State<ArtistVideos> createState() => _ArtistVideosState();
}

class _ArtistVideosState extends State<ArtistVideos> {
  @override
  void initState() {
    final currentState = context.read<FullArtistVideoBloc>().state;
    if (currentState.runtimeType != ArtistVideosDataState) {
      context
          .read<FullArtistVideoBloc>()
          .add(GetArtistVideosEvent(inputText: widget.artist.artist.name));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullArtistVideoBloc, FullArtistVideoBlocState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return loadingDisk();
        }
        if (state is ErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state is ArtistVideosDataState) {
          return state.artistVidoes.isEmpty
              ? Center(
                  child: Text(
                    "No videos found.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.artistVidoes.length,
                  itemBuilder: (context, index) {
                    final songData = state.artistVidoes[index];
                    return RecentSongTile(
                      songData: songData,
                      songIndex: index,
                      showDelete: false,
                      tabRouteENUM: TabRouteENUM.other,
                    );
                  },
                );
        }
        return const SizedBox();
      },
    );
  }
}
