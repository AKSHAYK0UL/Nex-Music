import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenSize * 0.0158),
          child: Text(
            "Recent",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
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
              child: ListView.builder(
                itemCount: state.recentPlayedList.length,
                itemBuilder: (context, index) {
                  final songData = state.recentPlayedList[index];
                  return SongTitle(songData: songData, songIndex: index);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
