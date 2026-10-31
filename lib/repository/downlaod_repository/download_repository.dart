import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nex_music/helper_function/delete_offline_songs/delete_offlice_songs.dart';
import 'package:nex_music/helper_function/load_offline_songs/loadsong.dart';
import 'package:nex_music/helper_function/lyrics_cache/lyrics_cache.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/download_provider.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:path_provider/path_provider.dart';

class DownloadRepo {
  final DownloadProvider _downloadProvider;

  DownloadRepo(this._downloadProvider);

  Stream<double> downloadSong(SongRawData songRawInfo, Songmodel songData) {
    try {
      final actualDownformat =
          songRawInfo.codecs.contains("mp") ? "m4a" : "opus";
      debugPrint("ACTUAL DOWNLOAD FORMATE $actualDownformat @@@@");
      return _downloadProvider.downloadSong(
        songRawInfo,
        actualDownformat,
        songData.toJson(),
      );
    } catch (_) {
      rethrow;
    }
  }

  Stream<List<Songmodel>> get loadOfflineSongs {
    return loadDownloadedSongsStream(); //helper function
  }

  //delete saved songs
  Future<void> deleteDownLoadedSong(Songmodel songData) async {
    try {
      await deleteDownloadedSong(songData);
    } catch (_) {
      rethrow;
    }
  }

  // Fetches lyrics for songData online and saves them alongside the
  // downloaded audio file on disk
  Future<void> saveLyricsForSong(
    Songmodel songData,
    Repository repository,
  ) async {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return;

      final fileName = songData.songName + songData.vId;
      final basePath = '${externalDir.path}/downloads/$fileName';

      // Skip if lyrics files already exist
      final lrcExists = File('$basePath.lrc').existsSync();
      final txtExists = File('$basePath.txt').existsSync();
      if (lrcExists && txtExists) return;

      final lyrics = await repository.getLyrics(
        title: songData.songName,
        artist: songData.artist.name,
        videoId: songData.vId,
        durationSeconds: _parseDuration(songData.duration),
      );

      if (lyrics != null && lyrics.hasLyrics) {
        await saveLyricsToFile(basePath, lyrics);
      }
    } catch (_) {
      // Silently ignore lyrics are optional
    }
  }

  static int? _parseDuration(String? dur) {
    if (dur == null || dur.trim().isEmpty) return null;
    final parts = dur.trim().split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final s = int.tryParse(parts[1]);
      if (m != null && s != null) return m * 60 + s;
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final s = int.tryParse(parts[2]);
      if (h != null && m != null && s != null) return h * 3600 + m * 60 + s;
    }
    return null;
  }
}
