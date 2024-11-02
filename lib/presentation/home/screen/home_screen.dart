import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/home/widget/playlistview.dart';
import 'package:nex_music/presentation/home/widget/songcolumview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return BlocBuilder<HomesectionBloc, HomesectionState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Loading();
        }
        if (state is ErrorState) {
          return Center(
            child: Text(
              state.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        if (state is HomeSectionState) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    showSnackbar(context, "Testing");
                  },
                  icon: Icon(
                    size: screenSize * 0.0369,
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
              title: Padding(
                padding: EdgeInsets.only(left: screenSize * 0.0158),
                child: Text(
                  "Quick Picks",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize * 0.0106,
                    vertical: screenSize * 0.0053),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenSize * 0.435,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (state.quickPicks.length / 4)
                            .ceil(), // Calculate the number of horizontal items
                        itemBuilder: (context, rowIndex) {
                          return SongColumView(
                              rowIndex: rowIndex,
                              quickPicksLength: state.quickPicks.length,
                              quickPicks: state.quickPicks);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenSize * 0.0106),
                      child: Text(
                        "Playlists For You",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: screenSize * 0.396,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.playlist.length,
                        itemBuilder: (context, index) {
                          final playlistData = state.playlist[index];
                          return PlaylistView(playList: playlistData);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
