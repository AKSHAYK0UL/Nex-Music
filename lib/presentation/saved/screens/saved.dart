import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nex_music/helper_function/loadsong.dart';
import 'package:nex_music/model/songmodel.dart';

class SavedSongs extends StatelessWidget {
  const SavedSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Songs")),
      body: FutureBuilder<List<Songmodel>>(
        future: loadDownloadedSongs(),
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
