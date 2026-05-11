import 'package:hive_ce/hive.dart';
import 'package:nex_music/constants/const.dart';
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
            audioQuality: data.audioQuality));
      } else {
        await box.putAt(
            0,
            HiveQuality(
                thumbnailQuality: data.thumbnailQuality,
                audioQuality: data.audioQuality));
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
        audioQuality: box.values.first.audioQuality);
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
}
