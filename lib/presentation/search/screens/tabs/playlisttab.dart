import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
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
    final currentState = context.read<SearchedplaylistBloc>().state;
    if (currentState.runtimeType != PlaylistDataState) {
      context
          .read<SearchedplaylistBloc>()
          .add(SearchInPlaylistEvent(inputText: widget.inputText));
    }

    super.initState();
  }

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
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    right: widget.screenSize * 0.00263,
                    left: widget.screenSize * 0.00263,
                    top: widget.screenSize * 0.0131),
                child: GridView.builder(
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
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
