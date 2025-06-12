import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';

Stream<List<Songmodel>> loadDownloadedSongsStream() async* {
  // if (Platform.isAndroid && !await _checkReadPermission()) {
  //   debugPrint(' Read permission denied');
  //   yield [];
  //   return;
  // }

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
        final mp3Path = '$basePath.mp3';
        final jpgPath = '$basePath.jpg';

        final hasMp3 = File(mp3Path).existsSync();
        final hasJpg = File(jpgPath).existsSync();

        if (!hasMp3) debugPrint("Missing MP3: $mp3Path");
        if (!hasJpg) debugPrint("Missing JPG: $jpgPath");

        if (hasMp3 && hasJpg) {
          final song = Songmodel.fromJson(jsonData).copyWith(
            thumbnail: jpgPath,
            isLocal: true,
            localFilePath: mp3Path,
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
