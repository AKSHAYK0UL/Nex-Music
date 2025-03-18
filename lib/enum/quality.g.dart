// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThumbnailQualityAdapter extends TypeAdapter<ThumbnailQuality> {
  @override
  final int typeId = 1;

  @override
  ThumbnailQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThumbnailQuality.high;
      case 1:
        return ThumbnailQuality.medium;
      case 2:
        return ThumbnailQuality.low;
      default:
        return ThumbnailQuality.high;
    }
  }

  @override
  void write(BinaryWriter writer, ThumbnailQuality obj) {
    switch (obj) {
      case ThumbnailQuality.high:
        writer.writeByte(0);
      case ThumbnailQuality.medium:
        writer.writeByte(1);
      case ThumbnailQuality.low:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThumbnailQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AudioQualityAdapter extends TypeAdapter<AudioQuality> {
  @override
  final int typeId = 2;

  @override
  AudioQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AudioQuality.high;
      case 1:
        return AudioQuality.medium;
      case 2:
        return AudioQuality.low;
      default:
        return AudioQuality.high;
    }
  }

  @override
  void write(BinaryWriter writer, AudioQuality obj) {
    switch (obj) {
      case AudioQuality.high:
        writer.writeByte(0);
      case AudioQuality.medium:
        writer.writeByte(1);
      case AudioQuality.low:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
