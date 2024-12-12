import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  @override
  void initState() {
    context.read<RecentplayedBloc>().add(GetRecentPlayedEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    List<Songmodel> recentSongs = [];
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenSize * 0.0158),
          child: Text(
            "Recents",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SongstreamBloc>().add(GetSongPlaylistEvent(
                  songlist: recentSongs)); //load recent songs in the playlist
              showSnackbar(context, "Playlist added");
            },
            icon: const Icon(CupertinoIcons.shuffle),
          ),
        ],
      ),
      body: BlocBuilder<RecentplayedBloc, RecentplayedState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is RecentPlayedSongsState) {
            return Padding(
              padding: EdgeInsets.only(
                right: screenSize * 0.0131,
                left: screenSize * 0.0131,
                top: screenSize * 0.0131,
              ),
              child: StreamBuilder(
                  stream: state.recentPlayedStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No recent songs played.'));
                    } else {
                      final recentData = snapshot.data!;
                      recentSongs = recentData;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: recentData.length,
                        itemBuilder: (context, index) {
                          final songData = recentData[index];
                          return SongTitle(
                            songData: songData,
                            songIndex: index,
                            showDelete: true,
                          );
                        },
                      );
                    }
                  }),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
