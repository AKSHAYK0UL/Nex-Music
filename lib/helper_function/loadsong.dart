// import 'dart:convert';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:nex_music/model/songmodel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<bool> _checkReadPermission() async {
//   if (Platform.isAndroid) {
//     final androidInfo = await DeviceInfoPlugin().androidInfo;
//     final sdkInt = androidInfo.version.sdkInt;

//     if (sdkInt >= 33) {
//       return await Permission.audio.request().isGranted;
//     } else {
//       return await Permission.storage.request().isGranted;
//     }
//   }
//   return true;
// }

// Future<List<Songmodel>> loadDownloadedSongs() async {
//   if (Platform.isAndroid && !await _checkReadPermission()) {
//     debugPrint('Read permission denied');
//     return [];
//   }

//   final Directory? externalDir = await getExternalStorageDirectory();
//   if (externalDir == null) {
//     debugPrint('External storage directory not found');
//     return [];
//   }

//   final downloadDir = Directory('${externalDir.path}/downloads');
//   if (!downloadDir.existsSync()) {
//     debugPrint('Download directory does not exist: ${downloadDir.path}');
//     return [];
//   }

//   debugPrint('Loading songs from: ${downloadDir.path}');

//   final List<Songmodel> songs = [];
//   final files = downloadDir.listSync();

//   for (var file in files) {
//     if (file is File && file.path.endsWith('.json')) {
//       try {
//         final jsonData = jsonDecode(await file.readAsString());
//         final basePath = file.path.replaceAll('.json', '');
//         final mp3Path = '$basePath.mp3';
//         final jpgPath = '$basePath.jpg';

//         if (File(mp3Path).existsSync() && File(jpgPath).existsSync()) {
//           songs.add(Songmodel.fromJson(jsonData).copyWith(thumbnail: jpgPath));
//           debugPrint('Found song: ${jsonData['songName']}');
//         } else {
//           debugPrint('Missing files for: $basePath');
//         }
//       } catch (e) {
//         debugPrint('Error loading ${file.path}: $e');
//       }
//     }
//   }

//   debugPrint('Total songs loaded: ${songs.length}');
//   return songs;
// }

//========================================================================

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Future<bool> _checkReadPermission() async {
//   if (Platform.isAndroid) {
//     final androidInfo = await DeviceInfoPlugin().androidInfo;
//     final sdkInt = androidInfo.version.sdkInt;

//     if (sdkInt >= 33) {
//       final permissions = await [
//         Permission.audio,
//         Permission.mediaLibrary,
//         Permission.videos,
//         Permission.photos,
//       ].request();

//       return permissions.values.any((p) => p.isGranted);
//     } else {
//       return await Permission.storage.request().isGranted;
//     }
//   }
//   return true;
// }

Future<bool> _checkReadPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final audio = await Permission.audio.request();
      final media = await Permission.mediaLibrary.request();
      final images = await Permission.photos.request();

      return audio.isGranted || media.isGranted || images.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }
  return true;
}

// Stream<List<Songmodel>> loadDownloadedSongsStream() async* {
//   if (Platform.isAndroid && !await _checkReadPermission()) {
//     debugPrint('🔴 Read permission denied');
//     yield [];
//     return;
//   }

//   final Directory? externalDir = await getExternalStorageDirectory();
//   if (externalDir == null) {
//     debugPrint('🔴 External storage directory not found');
//     yield [];
//     return;
//   }

//   final downloadDir = Directory('${externalDir.path}/downloads');
//   if (!downloadDir.existsSync()) {
//     debugPrint('🟡 Download directory does not exist: ${downloadDir.path}');
//     yield [];
//     return;
//   }

//   debugPrint('📂 Loading songs from: ${downloadDir.path}');

//   final List<Songmodel> songs = [];
//   final List<FileSystemEntity> files = downloadDir.listSync();

//   for (var file in files) {
//     debugPrint("📁 Found file: ${file.path}");

//     if (file is File && file.path.endsWith('.json')) {
//       try {
//         final jsonData = jsonDecode(await file.readAsString());
//         final basePath = file.path.replaceAll('.json', '');
//         final mp3Path = '$basePath.mp3';
//         final jpgPath = '$basePath.jpg';

//         final hasMp3 = File(mp3Path).existsSync();
//         final hasJpg = File(jpgPath).existsSync();

//         if (!hasMp3) debugPrint("❌ Missing MP3: $mp3Path");
//         if (!hasJpg) debugPrint("❌ Missing JPG: $jpgPath");

//         if (hasMp3 && hasJpg) {
//           final song = Songmodel.fromJson(
//             jsonData,
//           ).copyWith(thumbnail: jpgPath);
//           songs.add(song);
//           debugPrint('✅ Loaded song: ${song.songName}');
//           yield List.from(songs); // Emit the current list so far
//         }
//       } catch (e) {
//         debugPrint('❌ Error loading ${file.path}: $e');
//       }
//     }
//   }

//   debugPrint('✅ Total songs loaded: ${songs.length}');
// }

// Future<List<Songmodel>> loadDownloadedSongs() async {
//   if (Platform.isAndroid && !await _checkReadPermission()) {
//     debugPrint('🔴 Read permission denied');
//     return [];
//   }

//   final Directory? externalDir = await getExternalStorageDirectory();
//   if (externalDir == null) {
//     debugPrint('🔴 External storage directory not found');
//     return [];
//   }

//   final downloadDir = Directory('${externalDir.path}/downloads');
//   if (!downloadDir.existsSync()) {
//     debugPrint('🟡 Download directory does not exist: ${downloadDir.path}');
//     return [];
//   }

//   debugPrint('📂 Loading songs from: ${downloadDir.path}');

//   final List<Songmodel> songs = [];
//   final List<FileSystemEntity> files = downloadDir.listSync();

//   for (var file in files) {
//     debugPrint("📁 Found file: ${file.path}");

//     if (file is File && file.path.endsWith('.json')) {
//       try {
//         final jsonData = jsonDecode(await file.readAsString());
//         final basePath = file.path.replaceAll('.json', '');
//         final mp3Path = '$basePath.mp3';
//         final jpgPath = '$basePath.jpg';

//         final hasMp3 = File(mp3Path).existsSync();
//         final hasJpg = File(jpgPath).existsSync();

//         if (!hasMp3) debugPrint("❌ Missing MP3: $mp3Path");
//         if (!hasJpg) debugPrint("❌ Missing JPG: $jpgPath");

//         if (hasMp3 && hasJpg) {
//           final song =
//               Songmodel.fromJson(jsonData).copyWith(thumbnail: jpgPath);
//           songs.add(song);
//           debugPrint('✅ Loaded song: ${song.songName}');
//         }
//       } catch (e) {
//         debugPrint('❌ Error loading ${file.path}: $e');
//       }
//     }
//   }

//   debugPrint('✅ Total songs loaded: ${songs.length}');
//   return songs;
// }

Stream<List<Songmodel>> loadDownloadedSongsStream() async* {
  if (Platform.isAndroid && !await _checkReadPermission()) {
    debugPrint('🔴 Read permission denied');
    yield [];
    return;
  }

  final Directory? externalDir = await getExternalStorageDirectory();
  if (externalDir == null) {
    debugPrint('🔴 External storage directory not found');
    yield [];
    return;
  }

  final downloadDir = Directory('${externalDir.path}/downloads');
  if (!downloadDir.existsSync()) {
    debugPrint('🟡 Download directory does not exist: ${downloadDir.path}');
    yield [];
    return;
  }

  debugPrint('📂 Loading songs from: ${downloadDir.path}');

  final List<Songmodel> songs = [];
  final List<FileSystemEntity> files = downloadDir.listSync();

  for (var file in files) {
    debugPrint("📁 Found file: ${file.path}");

    if (file is File && file.path.endsWith('.json')) {
      try {
        final jsonData = jsonDecode(await file.readAsString());
        final basePath = file.path.replaceAll('.json', '');
        final mp3Path = '$basePath.mp3';
        final jpgPath = '$basePath.jpg';

        final hasMp3 = File(mp3Path).existsSync();
        final hasJpg = File(jpgPath).existsSync();

        if (!hasMp3) debugPrint("❌ Missing MP3: $mp3Path");
        if (!hasJpg) debugPrint("❌ Missing JPG: $jpgPath");

        if (hasMp3 && hasJpg) {
          final song = Songmodel.fromJson(jsonData).copyWith(
            thumbnail: jpgPath,
            isLocal: true,
            localFilePath: mp3Path,
          );
          songs.add(song);
          debugPrint('✅ Loaded song: ${song.songName}');
          yield List.from(songs); // Emit current list
        }
      } catch (e) {
        debugPrint('❌ Error loading ${file.path}: $e');
      }
    }
  }

  debugPrint('✅ Total songs loaded: ${songs.length}');
}
