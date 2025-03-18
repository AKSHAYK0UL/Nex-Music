import 'package:hive_ce/hive.dart';
import 'package:nex_music/enum/quality.dart';
@GenerateAdapters([AdapterSpec<HiveQuality>()])
part 'hive_quality_class.g.dart';

class HiveQuality extends HiveObject {
  ThumbnailQuality thumbnailQuality;
  AudioQuality audioQuality;
  HiveQuality({
    required this.thumbnailQuality,
    required this.audioQuality,
  });
}
