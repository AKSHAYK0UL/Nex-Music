import 'dart:io';

import 'package:nex_music/core/exceptions/dir_not_exists.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> deleteDownloadedSong(Songmodel songData) async {
  try {
    final Directory? extrenalDir = await getExternalStorageDirectory();
    if (extrenalDir == null) {
      throw Exception(DirNotExistsException());
    }

    final fileName = songData.songName + songData.vId;
    final basePath = "${extrenalDir.path}/downloads/$fileName";
    final songFilePath = "$basePath.${songData.audioFormat}";
    final thumbnailFilePath = "$basePath.jpg";
    final metadataFilePath = "$basePath.json";

    final songFile = File(songFilePath);
    final thumbnailFile = File(thumbnailFilePath);
    final metadataFile = File(metadataFilePath);

    if (await songFile.exists()) {
      await songFile.delete();
      return;
    }

    if (await thumbnailFile.exists()) {
      await thumbnailFile.delete();
      return;
    }

    if (await metadataFile.exists()) {
      await metadataFile.delete();
      return;
    }
  } catch (_) {
    rethrow;
  }
}
