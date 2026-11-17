import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:nex_music/constants/const.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_paused_download.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';

class HiveDataBaseSingleton {
  static final HiveDataBaseSingleton instance =
      HiveDataBaseSingleton._internal();

  HiveDataBaseSingleton._internal();

//get Box
  Box<HiveQuality> get getBox {
    final hiveDB = Hive.box<HiveQuality>(qualitySettingsBox);
    return hiveDB;
  }

  //Save [add task]
  Future<void> save(HiveQuality data) async {
    try {
      final box = getBox;

      if (box.isEmpty) {
        await box.add(HiveQuality(
            thumbnailQuality: data.thumbnailQuality,
            audioQuality: data.audioQuality,
            downloadQuality: data.downloadQuality));
      } else {
        await box.putAt(
            0,
            HiveQuality(
                thumbnailQuality: data.thumbnailQuality,
                audioQuality: data.audioQuality,
                downloadQuality: data.downloadQuality));
      }
    } catch (_) {
      rethrow;
    }
  }

  //get
  HiveQuality get getData {
    final box = getBox;
    return HiveQuality(
        thumbnailQuality: box.values.first.thumbnailQuality,
        audioQuality: box.values.first.audioQuality,
        downloadQuality: box.values.first.downloadQuality);
  }

  // THINK Box
  Box<bool> get getThinkBox {
    final box = Hive.box<bool>(thinkBox);
    return box;
  }

  // THEME Box
  Box<bool> get getThemeBox {
    final box = Hive.box<bool>(themeBox);
    return box;
  }

  //update
  Future<void> saveRecommendation(bool value) async {
    try {
      final box = getThinkBox;
      if (box.isEmpty) {
        await box.add(value);
      } else {
        await box.putAt(0, value);
      }
    } catch (_) {
      rethrow;
    }
  }

  //status
  bool get recommendationStatus {
    final box = getThinkBox;
    return box.values.first;
  }

  // Save dark mode preference
  Future<void> saveDarkMode(bool isDark) async {
    try {
      final box = getThemeBox;
      if (box.isEmpty) {
        await box.add(isDark);
      } else {
        await box.putAt(0, isDark);
      }
    } catch (_) {
      rethrow;
    }
  }

  // Get dark mode preference (defaults to false -> light)
  bool get isDarkMode {
    final box = getThemeBox;
    if (box.isEmpty) return false;
    return box.values.first;
  }

  // LYRICS SYNC Box
  Box<int> get getLyricsSyncBox {
    return Hive.box<int>(lyricsSyncOffsetsBox);
  }

  Duration getLyricSyncOffset(String videoId, String sourceName) {
    try {
      final ms = getLyricsSyncBox.get('${videoId}_$sourceName') ?? 0;
      return Duration(milliseconds: ms);
    } catch (_) {
      return Duration.zero;
    }
  }

  Future<void> saveLyricSyncOffset(
    String videoId,
    String sourceName,
    int offsetMs,
  ) async {
    try {
      await getLyricsSyncBox.put('${videoId}_$sourceName', offsetMs);
    } catch (_) {}
  }

  // CDN PREFERENCE Box stores a single bool (true = CDN enabled).
  Box<bool> get _cdnBox => Hive.box<bool>(cdnPreferenceBox);

  // Returns true when the user has CDN cache loading enabled.
  // Defaults to true (opt-in by default).
  bool get cdnEnabled {
    final box = _cdnBox;
    if (box.isEmpty) return true;
    return box.values.first;
  }

  Future<void> saveCdnEnabled(bool value) async {
    try {
      final box = _cdnBox;
      if (box.isEmpty) {
        await box.add(value);
      } else {
        await box.putAt(0, value);
      }
    } catch (_) {}
  }

  // PAUSED DOWNLOADS Box — keyed by vId.
  Box<HivePausedDownload> get _pausedBox =>
      Hive.box<HivePausedDownload>(pausedDownloadsBox);

  // Persist a single paused/pending task.
  Future<void> savePausedDownload(HivePausedDownload entry) async {
    try {
      await _pausedBox.put(entry.vId, entry);
    } catch (e) {
      debugPrint('Error saving paused download (${entry.vId}): $e');
    }
  }

  // Remove a single entry (task completed or cancelled).
  Future<void> removePausedDownload(String vId) async {
    try {
      await _pausedBox.delete(vId);
    } catch (e) {
      debugPrint('Error removing paused download ($vId): $e');
    }
  }

  // All currently persisted paused tasks.
  List<HivePausedDownload> get allPausedDownloads {
    try {
      return _pausedBox.values.toList();
    } catch (e) {
      debugPrint('Error getting all paused downloads: $e');
      return [];
    }
  }

  // YT MUSIC COOKIE Box
  Box<String> get getYtMusicCookieBox {
    return Hive.box<String>(ytMusicCookieBox);
  }

  Future<void> saveYtMusicCookie(String cookie) async {
    try {
      final box = getYtMusicCookieBox;
      await box.put(ytMusicCookieKey, cookie);
    } catch (e) {
      debugPrint('Error saving YT Music cookie: $e');
    }
  }

  String? get ytMusicCookie {
    try {
      final box = getYtMusicCookieBox;
      return box.get(ytMusicCookieKey);
    } catch (e) {
      debugPrint('Error reading YT Music cookie: $e');
      return null;
    }
  }

  Future<void> clearYtMusicCookie() async {
    try {
      final box = getYtMusicCookieBox;
      await box.delete(ytMusicCookieKey);
    } catch (e) {
      debugPrint('Error clearing YT Music cookie: $e');
    }
  }

  bool get isYtMusicLoggedIn =>
      ytMusicCookie != null && ytMusicCookie!.isNotEmpty;
}
