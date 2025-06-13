import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/core/exceptions/file_exist.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:path_provider/path_provider.dart';

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
    SongRawData songRawInfo,
    String actualDownformat,
    Map<String, dynamic> songDataMap,
  ) {
    final fileName = songDataMap["song_name"] + songDataMap["v_id"];
    final thumbnailUrl =
        "https://i.ytimg.com/vi/${songDataMap["v_id"]}/maxresdefault.jpg";
    final metadata = songDataMap;
    final controller = StreamController<double>();

    () async {
      try {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          // controller.add(-1);
          controller.addError("Directory not exist");

          await controller.close();
          return;
        }

        final downloadDir = Directory('${externalDir.path}/downloads');
        if (!downloadDir.existsSync()) {
          await downloadDir.create(recursive: true);
        }

        final basePath = "${downloadDir.path}/$fileName";
        final songFilePath = "$basePath.$actualDownformat";
        final thumbnailFilePath = "$basePath.jpg";
        final metadataFilePath = "$basePath.json";

        debugPrint('Downloading to: $basePath');

        // Download song
        if (!await File(songFilePath).exists()) {
          await _dio.download(
            songRawInfo.url.toString(),
            songFilePath,
            deleteOnError: true,
            options: Options(
                headers: {"Range": 'bytes=0-${songRawInfo.totalBytes}'}),
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

          controller.addError(FileExistException());
          await controller.close();
        }

        // Download thumbnail
        if (!await File(thumbnailFilePath).exists()) {
          // print("Thumbnail URL ${thumbnailUrl} @@@@@@");
          try {
            await _dio.download(thumbnailUrl, thumbnailFilePath);
          } catch (e) {
            debugPrint("Failed to download thumbnail: $e");
            controller.addError("Failed to download thumbnail");
          }
        }

        // Save metadata
        if (!await File(metadataFilePath).exists()) {
          try {
            await File(metadataFilePath).writeAsString(jsonEncode(metadata));
          } catch (e) {
            debugPrint("Failed to write metadata: $e");
            controller.addError("Failed to write metadata");
          }
        }

        controller.add(100.0);
        await controller.close();
      } catch (e) {
        debugPrint('Download failed: $e');
        controller.addError("Download failed");
        await controller.close();
      }
    }();

    return controller.stream;
  }
}
