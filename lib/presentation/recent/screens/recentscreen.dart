import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/core/wrapper/song_filter_wrapper.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';



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
    // The Wrapper now handles the Scaffold and background color
    return BlocBuilder<RecentplayedBloc, RecentplayedState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is RecentPlayedSongsState) {
          return StreamBuilder<List<Songmodel>>(
            stream: state.recentPlayedStream,
            builder: (context, snapshot) {
              
              // Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.red.withValues(alpha: 0.8),
                      radius: 15,
                    ),
                  ),
                );
              }

              // Error State
              if (snapshot.hasError) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(child: Text(snapshot.error.toString())),
                );
              }

              final songs = snapshot.data ?? [];

              // Empty State
              if (songs.isEmpty) {
                return const Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Text(
                      'No recent songs played.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Data Loaded State - Use the Wrapper
              return SongFilterWrapper(
                title: 'Recent',
                songs: songs,
                tabRoute: TabRouteENUM.recent,
                builder: (context, filteredSongs) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      return RecentSongTile(
                        songData: filteredSongs[index],
                        songIndex: index,
                        tabRouteENUM: TabRouteENUM.recent,
                      );
                    },
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}