import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class SavedSongs extends StatefulWidget {
  const SavedSongs({super.key});

  @override
  State<SavedSongs> createState() => _SavedSongsState();
}

class _SavedSongsState extends State<SavedSongs> {
  ValueNotifier<bool> switchState = ValueNotifier(false);
  List<Songmodel> downloadedSongs = [];
  @override
  void initState() {
    print(" LoadOfflineSongsEvent @@@@@");
    context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenSize * 0.0131),
          child: const Text("Saved"),
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
                          .add(GetSongPlaylistEvent(songlist: downloadedSongs));
                      showSnackbar(context, "Now playing your Saved songs");
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
      body: BlocBuilder<OfflineSongsBloc, OfflineSongsState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is OfflineSongsLoadingState) {
            return CircularProgressIndicator(
              color: accentColor,
            );
          }
          if (state is OfflineSongsErrorState) {
            return Text(state.errorMessage);
          }
          if (state is OfflineSongsDataState) {
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No downloaded songs found.'));
                  }

                  final songs = snapshot.data!;
                  downloadedSongs = songs;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final songData = songs[index];
                      return SongTitle(
                          songData: songData,
                          songIndex: index,
                          showDelete: true,
                          tabRouteENUM: TabRouteENUM.download);
                    },
                  );
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
