import 'package:hive_ce/hive.dart';

part 'quality.g.dart';

@HiveType(typeId: 1)
enum ThumbnailQuality {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

@HiveType(typeId: 2)
enum AudioQuality {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}
