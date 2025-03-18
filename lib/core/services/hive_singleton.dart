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
  }

  //get
  Future<HiveQuality> get getData async {
    final box = getBox;
    return HiveQuality(
        thumbnailQuality: box.values.first.thumbnailQuality,
        audioQuality: box.values.first.audioQuality);
  }
}
