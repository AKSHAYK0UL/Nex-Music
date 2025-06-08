import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_playlist_songs_bloc/bloc/user_playlist_song_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class UserPlaylistSongs extends StatefulWidget {
  static const routeName = "/userplaylistsongs";
  const UserPlaylistSongs({super.key});

  @override
  State<UserPlaylistSongs> createState() => _UserPlaylistSongsState();
}

class _UserPlaylistSongsState extends State<UserPlaylistSongs> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistName = ModalRoute.of(context)?.settings.arguments as String;
      context
          .read<UserPlaylistSongBloc>()
          .add(GetuserPlaylistSongsEvent(playlistName: playlistName));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final playlistName = ModalRoute.of(context)?.settings.arguments as String;
    ValueNotifier<bool> switchState = ValueNotifier(false);
    List<Songmodel> playlistSongs = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          playlistName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: switchState,
            builder: (__, ___, _) {
              return Padding(
                padding: EdgeInsets.only(right: screenSize * 0.0131),
                child: IconButton(
                  onPressed: () {
                    switchState.value = !switchState.value;
                    if (switchState.value) {
                      context.read<SongstreamBloc>().add(ResetPlaylistEvent());
                      context
                          .read<SongstreamBloc>()
                          .add(GetSongPlaylistEvent(songlist: playlistSongs));
                      showSnackbar(context, "Playing $playlistName playlist");
                    } else {
                      context.read<SongstreamBloc>().add(CleanPlaylistEvent());
                    }
                  },
                  icon: Icon(
                    Icons.queue_music,
                    size: screenSize * 0.038,
                    color: switchState.value ? accentColor : Colors.grey,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<UserPlaylistSongBloc, UserPlaylistSongState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is UserPlaylistSongSongsDataState) {
            return Padding(
              padding: EdgeInsets.only(
                right: screenSize * 0.0131,
                left: screenSize * 0.0131,
                top: screenSize * 0.0131,
              ),
              child: StreamBuilder<List<Songmodel>>(
                  stream: state.data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Song found!'));
                    }
                    final songsData = snapshot.data;
                    playlistSongs = songsData!;
                    return ListView.builder(
                        itemCount: songsData.length,
                        itemBuilder: (context, index) {
                          return SongTitle(
                            songData: songsData[index],
                            songIndex: index,
                            showDelete: true,
                            tabRouteENUM: TabRouteENUM.playlist,
                            playlistName: playlistName,
                          );
                        });
                  }),
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: MiniPlayer(screenSize: screenSize),
    );
  }
}
