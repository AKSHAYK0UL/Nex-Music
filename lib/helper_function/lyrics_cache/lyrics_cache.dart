import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:path_provider/path_provider.dart';

// Saves lyrics for a downloaded song to disk.
// Files saved:
//   `<basePath>.lrc`   raw synced LRC text (if synced lyrics exist)
//   `<basePath>.txt`   plain text lyrics (always, if any lyrics exist)
Future<void> saveLyricsToFile(String basePath, LyricModel lyrics) async {
  try {
    if (lyrics.plainLyrics != null && lyrics.plainLyrics!.trim().isNotEmpty) {
      final plainFile = File('$basePath.txt');
      if (!await plainFile.exists()) {
        await plainFile.writeAsString(lyrics.plainLyrics!);
        debugPrint('[LyricsCache] Saved plain lyrics: ${plainFile.path}');
      }
    }

    if (lyrics.hasSyncedLyrics) {
      final lrcContent = _toLrcString(lyrics.syncedLyrics);
      final lrcFile = File('$basePath.lrc');
      if (!await lrcFile.exists()) {
        await lrcFile.writeAsString(lrcContent);
        debugPrint('[LyricsCache] Saved synced lyrics: ${lrcFile.path}');
      }
    }
  } catch (e) {
    debugPrint('[LyricsCache] Failed to save lyrics: $e');
  }
}

// Reconstructs an LRC string from a list of [LyricLine]s.
String _toLrcString(List<LyricLine> lines) {
  final buffer = StringBuffer();
  for (final line in lines) {
    final ts = line.timestamp;
    final mm = ts.inMinutes.toString().padLeft(2, '0');
    final ss = (ts.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (ts.inMilliseconds % 1000).toString().padLeft(3, '0');
    buffer.writeln('[$mm:$ss.$ms]${line.text}');
  }
  return buffer.toString();
}

// Tries to load locally saved lyrics for a downloaded song.
// Returns a [LyricModel] if any lyrics file is found, otherwise `null`.
Future<LyricModel?> loadLyricsFromFile(String songName, String vId) async {
  try {
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) return null;

    final fileName = songName + vId;
    final basePath = '${externalDir.path}/downloads/$fileName';

    final lrcFile = File('$basePath.lrc');
    final txtFile = File('$basePath.txt');

    List<LyricLine> syncedLines = [];
    String? plainLyrics;

    if (await lrcFile.exists()) {
      final lrcContent = await lrcFile.readAsString();
      syncedLines = LyricModel.parseLrc(lrcContent);
      debugPrint('[LyricsCache] Loaded synced lyrics from disk.');
    }

    if (await txtFile.exists()) {
      plainLyrics = await txtFile.readAsString();
      debugPrint('[LyricsCache] Loaded plain lyrics from disk.');
    }

    if (syncedLines.isNotEmpty ||
        (plainLyrics != null && plainLyrics.trim().isNotEmpty)) {
      return LyricModel(
        plainLyrics: plainLyrics,
        syncedLyrics: syncedLines,
      );
    }
  } catch (e) {
    debugPrint('[LyricsCache] Failed to load lyrics: $e');
  }
  return null;
}

// Deletes lyrics files (.lrc and .txt) for a downloaded song.
Future<void> deleteLyricsFiles(String basePath) async {
  for (final ext in ['.lrc', '.txt']) {
    try {
      final f = File('$basePath$ext');
      if (await f.exists()) {
        await f.delete();
        debugPrint('[LyricsCache] Deleted: ${f.path}');
      }
    } catch (e) {
      debugPrint('[LyricsCache] Failed to delete $basePath$ext: $e');
    }
  }
}
