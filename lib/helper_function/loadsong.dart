import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _checkReadPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      return await Permission.audio.request().isGranted;
    } else {
      return await Permission.storage.request().isGranted;
    }
  }
  return true;
}

Future<List<Songmodel>> loadDownloadedSongs() async {
  if (Platform.isAndroid && !await _checkReadPermission()) {
    debugPrint('Read permission denied');
    return [];
  }

  final Directory? externalDir = await getExternalStorageDirectory();
  if (externalDir == null) {
    debugPrint('External storage directory not found');
    return [];
  }

  final downloadDir = Directory('${externalDir.path}/downloads');
  if (!downloadDir.existsSync()) {
    debugPrint('Download directory does not exist: ${downloadDir.path}');
    return [];
  }

  debugPrint('Loading songs from: ${downloadDir.path}');

  final List<Songmodel> songs = [];
  final files = downloadDir.listSync();

  for (var file in files) {
    if (file is File && file.path.endsWith('.json')) {
      try {
        final jsonData = jsonDecode(await file.readAsString());
        final basePath = file.path.replaceAll('.json', '');
        final mp3Path = '$basePath.mp3';
        final jpgPath = '$basePath.jpg';

        if (File(mp3Path).existsSync() && File(jpgPath).existsSync()) {
          songs.add(Songmodel.fromJson(jsonData).copyWith(thumbnail: jpgPath));
          debugPrint('Found song: ${jsonData['songName']}');
        } else {
          debugPrint('Missing files for: $basePath');
        }
      } catch (e) {
        debugPrint('Error loading ${file.path}: $e');
      }
    }
  }

  debugPrint('Total songs loaded: ${songs.length}');
  return songs;
}
