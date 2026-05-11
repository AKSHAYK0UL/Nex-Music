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

    // Check for both possible audio formats
    final baseFileName = songData.vId.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final m4aPath = '${downloadDir.path}/$baseFileName.m4a';
    final opusPath = '${downloadDir.path}/$baseFileName.opus';

    return File(m4aPath).existsSync() || File(opusPath).existsSync();
  } catch (e) {
    return false;
  }
}
