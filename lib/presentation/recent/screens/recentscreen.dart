import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent"),
      ),
      body: BlocBuilder<RecentplayedBloc, RecentplayedState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is RecentPlayedSongsState) {
            return ListView.builder(
              itemCount: state.recentPlayedList.length,
              itemBuilder: (context, index) {
                final songData = state.recentPlayedList[index];
                return SongTitle(songData: songData, songIndex: index);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
