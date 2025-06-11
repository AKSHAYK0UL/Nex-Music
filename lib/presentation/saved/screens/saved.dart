import 'package:flutter/material.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/helper_function/loadsong.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class SavedSongs extends StatefulWidget {
  const SavedSongs({super.key});

  @override
  State<SavedSongs> createState() => _SavedSongsState();
}

class _SavedSongsState extends State<SavedSongs> {
  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   loadDownloadedSongsStream();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: EdgeInsets.only(left: screenSize * 0.0131),
        child: const Text("Saved"),
      )),
      body: StreamBuilder<List<Songmodel>>(
        stream: loadDownloadedSongsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No downloaded songs found.'));
          }

          final songs = snapshot.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final songData = songs[index];
              return SongTitle(
                  songData: songData,
                  songIndex: index,
                  showDelete: true,
                  tabRouteENUM: TabRouteENUM.download);

              //     ListTile(
              //       leading: Image.file(
              //         File(song.thumbnail),
              //         width: 50,
              //         height: 50,
              //         fit: BoxFit.cover,
              //         errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
              //       ),
              //       title: Text(song.songName),
              //       subtitle: Text(song.artist.name),
              //       trailing: Text(song.duration),
              //       onTap: () {
              //         final audioPath = song.thumbnail.replaceAll('.jpg', '.mp3');
              //         context
              //             .read<SongstreamBloc>()
              //             .add(GetSongStreamEvent(songData: song, songIndex: 0));
              //         //TODO:
              //         // Play song using File(audioPath)
              //       },
              //     );
            },
          );
        },
      ),
    );
  }
}
