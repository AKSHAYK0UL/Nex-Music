import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_songs_bloc/bloc/user_playlist_song_bloc.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
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
    final playlistName = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
        appBar: AppBar(
          title: Text(playlistName),
        ),
        body: BlocBuilder<UserPlaylistSongBloc, UserPlaylistSongState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is UserPlaylistSongSongsDataState) {
              return StreamBuilder<List<Songmodel>>(
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
                      return const Center(child: Text('No Songs'));
                    }
                    final songData = snapshot.data;
                    return ListView.builder(
                        itemCount: songData!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {},
                              title: SongTitle(
                                  songData: songData[index],
                                  songIndex: index,
                                  showDelete: true,
                                  tabRouteENUM: TabRouteENUM.playlist));
                        });
                  });
            }
            return const SizedBox();
          },
        ));
  }
}
