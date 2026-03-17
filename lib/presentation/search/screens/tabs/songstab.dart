import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart' as songbloc;
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

class SongsTab extends StatefulWidget {
  final String inputText;
  final double screenSize;
  const SongsTab({super.key, required this.inputText, required this.screenSize});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<songbloc.SongBloc>().state;
    if (currentState.runtimeType != songbloc.SongsResultState) {
      context.read<songbloc.SongBloc>().add(
            songbloc.SeachInSongEvent(inputText: widget.inputText),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<songbloc.SongBloc, songbloc.SongState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is songbloc.LoadingState) return loadingDisk();
        if (state is songbloc.SongsResultState) {
          if (state.searchedSongs.isEmpty) {
            return const Center(child: Text("No songs found", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: state.searchedSongs.length,
            itemBuilder: (context, index) {
              return RecentSongTile(
                songData: state.searchedSongs[index],
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