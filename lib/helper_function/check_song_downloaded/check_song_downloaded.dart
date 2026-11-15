import 'dart:io';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';

// Checks if a song is actually downloaded by verifying the audio file exists.
Future<bool> isSongDownloaded(Songmodel songData) async {
  try {
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) return false;

    final downloadDir = Directory('${externalDir.path}/downloads');
    if (!downloadDir.existsSync()) return false;

    final fileName = songData.songName + songData.vId;
    final basePath = '${downloadDir.path}/$fileName';
    final metadataFile = File('$basePath.json');
    if (!metadataFile.existsSync()) return false;

    final m4aPath = '$basePath.m4a';
    final opusPath = '$basePath.opus';

    return File(m4aPath).existsSync() || File(opusPath).existsSync();
  } catch (e) {
    return false;
  }
}
