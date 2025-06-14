import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';

Stream<List<Songmodel>> loadDownloadedSongsStream() async* {
  final Directory? externalDir = await getExternalStorageDirectory();
  if (externalDir == null) {
    debugPrint('External storage directory not found');
    yield [];
    return;
  }

  final downloadDir = Directory('${externalDir.path}/downloads');
  if (!downloadDir.existsSync()) {
    debugPrint('Download directory does not exist: ${downloadDir.path}');
    yield [];
    return;
  }

  debugPrint('Loading songs from: ${downloadDir.path}');

  final List<Songmodel> songs = [];
  final List<FileSystemEntity> files = downloadDir.listSync();

  for (var file in files) {
    debugPrint("Found file: ${file.path}");

    if (file is File && file.path.endsWith('.json')) {
      try {
        final jsonData = jsonDecode(await file.readAsString());
        final basePath = file.path.replaceAll('.json', '');

        final isM4a =
            jsonData['audioCodec']?.toString().contains('mp') ?? false;
        final audioExtension = isM4a ? 'm4a' : 'opus';

        final audioPath = '$basePath.$audioExtension';
        final imagePath = '$basePath.jpg';

        final hasAudioFile = File(audioPath).existsSync();
        final hasJpg = File(imagePath).existsSync();

        if (!hasAudioFile) debugPrint("Missing Audio File: $audioPath");
        if (!hasJpg) debugPrint("Missing JPG: $imagePath");

        if (hasAudioFile && hasJpg) {
          final song = Songmodel.fromJson(jsonData).copyWith(
            thumbnail: imagePath,
            isLocal: true,
            localFilePath: audioPath,
          );
          songs.add(song);
          debugPrint('Loaded song: ${song.songName}');
          yield List.from(songs); // Emit current list
        }
      } catch (e) {
        debugPrint('Error loading ${file.path}: $e');
      }
    }
  }

  debugPrint('Total songs loaded: ${songs.length}');
}
