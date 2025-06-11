import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadProvider {
  final Dio _dio;

  DownloadProvider({required Dio dio}) : _dio = dio {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 2),
    );
  }

  Stream<double> downloadSong(
    String songUrl,
    String fileName,
    String thumbnailUrl,
    Songmodel metadata,
  ) {
    final controller = StreamController<double>();

    () async {
      try {
        final granted = await _requestStorage();
        if (!granted) {
          debugPrint('Storage permission denied');
          controller.add(-1);
          await controller.close();
          return;
        }

        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          controller.add(-1);
          await controller.close();
          return;
        }

        final downloadDir = Directory('${externalDir.path}/downloads');
        if (!downloadDir.existsSync()) {
          await downloadDir.create(recursive: true);
        }

        final basePath = "${downloadDir.path}/$fileName";
        final songFilePath = "$basePath.mp3";
        final thumbnailFilePath = "$basePath.jpg";
        final metadataFilePath = "$basePath.json";

        debugPrint('Downloading to: $basePath');

        // Download song
        if (!await File(songFilePath).exists()) {
          await _dio.download(
            songUrl,
            songFilePath,
            deleteOnError: true,
            onReceiveProgress: (received, total) {
              if (total > 0) {
                final percent = (received / total) * 100;
                debugPrint("DOWNLOAD PERCENTAGE $percent %");
                controller.add(percent);
              }
            },
          );
        } else {
          debugPrint('File already exists: $songFilePath');
          controller.add(100.0);
        }

        // Download thumbnail (non-blocking)
        if (!await File(thumbnailFilePath).exists()) {
          try {
            await _dio.download(thumbnailUrl, thumbnailFilePath);
          } catch (e) {
            debugPrint("Failed to download thumbnail: $e");
          }
        }

        // Save metadata (non-blocking)
        if (!await File(metadataFilePath).exists()) {
          try {
            await File(metadataFilePath)
                .writeAsString(jsonEncode(metadata.toJson()));
          } catch (e) {
            debugPrint("Failed to write metadata: $e");
          }
        }

        controller.add(100.0);
        await controller.close();
      } catch (e) {
        debugPrint('Download failed: $e');
        controller.add(-1);
        await controller.close();
      }
    }();

    return controller.stream;
  }
}

Future<bool> _requestStorage() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final audio = await Permission.audio.request();
      return audio.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  } else {
    return true;
  }
}
