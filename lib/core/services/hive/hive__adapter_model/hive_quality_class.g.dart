// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_quality_class.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class HiveQualityAdapter extends TypeAdapter<HiveQuality> {
  @override
  final int typeId = 0;

  @override
  HiveQuality read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveQuality(
      thumbnailQuality: fields[0] as ThumbnailQuality,
      audioQuality: fields[1] as AudioQuality,
    );
  }

  @override
  void write(BinaryWriter writer, HiveQuality obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.thumbnailQuality)
      ..writeByte(1)
      ..write(obj.audioQuality);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
