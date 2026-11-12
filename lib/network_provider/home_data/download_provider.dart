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

  // Downloads a song and streams progress events (00 – 100).
  //cancelToken can be cancelled externally to abort the download.
  // resumeFromBytes is the number of bytes already written to disk;
  // when non-zero a Range header is sent so the download resumes.
  Stream<double> downloadSong(
    SongRawData songRawInfo,
    String actualDownformat,
    Map<String, dynamic> songDataMap, {
    CancelToken? cancelToken,
    int resumeFromBytes = 0,
  }) {
    final fileName = songDataMap["song_name"] + songDataMap["v_id"];
    final thumbnailUrl =
        "https://i.ytimg.com/vi/${songDataMap["v_id"]}/maxresdefault.jpg";
    final metadata = songDataMap;
    final controller = StreamController<double>();

    () async {
      try {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
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

        debugPrint('Downloading to: $basePath (resumeFrom: $resumeFromBytes)');

        //  Download audio file 
        if (!await File(songFilePath).exists()) {
          final int totalBytes = songRawInfo.totalBytes;

          // Build range header: start from resumeFromBytes if resuming.
          final String rangeHeader = resumeFromBytes > 0
              ? 'bytes=$resumeFromBytes-$totalBytes'
              : 'bytes=0-$totalBytes';

          await _dio.download(
            songRawInfo.url.toString(),
            songFilePath,
            deleteOnError: true,
            cancelToken: cancelToken,
            options: Options(headers: {"Range": rangeHeader}),
            onReceiveProgress: (received, total) {
              // `total` from the response may be the remaining bytes when
              // resuming add the already downloaded bytes for true percent.
              final int actualReceived = received + resumeFromBytes;
              final int actualTotal =
                  (total > 0) ? (total + resumeFromBytes) : totalBytes;
              if (actualTotal > 0) {
                final percent = (actualReceived / actualTotal) * 100;
                debugPrint(
                  "DOWNLOAD ${percent.toStringAsFixed(1)}% "
                  "(${_fmtBytes(actualReceived)} / ${_fmtBytes(actualTotal)})",
                );
                controller.add(percent.clamp(0.0, 100.0));
              }
            },
          );
        } else {
          debugPrint('File already exists: $songFilePath');
          controller.addError(FileExistException());
          await controller.close();
          return;
        }

        //  Download thumbnail 
        if (!await File(thumbnailFilePath).exists()) {
          try {
            await _dio.download(
              thumbnailUrl,
              thumbnailFilePath,
              cancelToken: cancelToken,
            );
          } catch (e) {
            debugPrint("Thumbnail download failed (non-fatal): $e");
            // Try a lower resolution fallback thumbnail.
            try {
              final fallback =
                  "https://i.ytimg.com/vi/${songDataMap["v_id"]}/hqdefault.jpg";
              await _dio.download(
                fallback,
                thumbnailFilePath,
                cancelToken: cancelToken,
              );
            } catch (_) {}
          }
        }

        //  Save metadata 
        if (!await File(metadataFilePath).exists()) {
          try {
            await File(metadataFilePath).writeAsString(jsonEncode(metadata));
          } catch (e) {
            debugPrint("Failed to write metadata: $e");
          }
        }

        controller.add(100.0);
        await controller.close();
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          // Cancelled
          debugPrint('Download cancelled for ${songDataMap["song_name"]}');
          await controller.close();
        } else {
          debugPrint('Dio Download Error: $e');
          controller.addError("Download Error: ${e.message}");
          await controller.close();
        }
      } catch (e) {
        debugPrint('Download Error: $e');
        controller.addError("Download Error");
        await controller.close();
      }
    }();

    return controller.stream;
  }
}

String _fmtBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
}
