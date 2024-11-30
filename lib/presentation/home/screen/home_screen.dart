import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
import 'package:nex_music/presentation/home/widget/home_playlist.dart';
import 'package:nex_music/presentation/home/widget/songcolumview.dart';
import 'package:nex_music/presentation/search/screens/search_screen.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as info;

class HomeScreen extends StatefulWidget {
  final User currentUser;
  const HomeScreen({
    super.key,
    required this.currentUser,
  });

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
          context
              .read<ss.SongstreamBloc>()
              .add(ss.GetSongPlaylistEvent(songlist: state.quickPicks));
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                  icon: Icon(
                    size: screenSize * 0.0369,
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // context.read<auth.AuthBloc>().add(auth.SignOutEvent());
                    Navigator.of(context).pushNamed(info.UserInfo.routeName,
                        arguments: widget.currentUser);
                  },
                  icon: Icon(
                    size: screenSize * 0.0369,
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ],
              title: Padding(
                padding: EdgeInsets.only(left: screenSize * 0.0158),
                child: const Text(
                  "Quick Picks",
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
                      height: screenSize * 0.440, //435
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (state.quickPicks.length / 4)
                            .ceil(), // Calculate the number of horizontal items
                        itemBuilder: (context, rowIndex) {
                          return SongColumView(
                            rowIndex: rowIndex,
                            quickPicksLength: state.quickPicks.length,
                            quickPicks: state.quickPicks,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenSize * 0.0106),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Playlists For You",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ShowAllPlaylists.routeName);
                            },
                            child: Container(
                              color: Colors.transparent,
                              width: screenSize * 0.080,
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: screenSize * 0.0290,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize * 0.345,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.playlist.length >= 6
                            ? 6
                            : state.playlist.length,
                        itemBuilder: (context, index) {
                          final playlistData = state.playlist[index];
                          return HomePlaylist(playList: playlistData);
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
