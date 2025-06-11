import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/helper_function/loadsong.dart';
import 'package:nex_music/model/songmodel.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Songs")),
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
              final song = songs[index];
              return ListTile(
                leading: Image.file(
                  File(song.thumbnail),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                ),
                title: Text(song.songName),
                subtitle: Text(song.artist.name),
                trailing: Text(song.duration),
                onTap: () {
                  final audioPath = song.thumbnail.replaceAll('.jpg', '.mp3');
                  context
                      .read<SongstreamBloc>()
                      .add(GetSongStreamEvent(songData: song, songIndex: 0));
                  //TODO:
                  // Play song using File(audioPath)
                },
              );
            },
          );
        },
      ),
    );
  }
}
