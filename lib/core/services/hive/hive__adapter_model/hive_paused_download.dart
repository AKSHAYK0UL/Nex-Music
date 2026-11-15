import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:nex_music/model/songmodel.dart';

class HivePausedDownload extends HiveObject {
  final String vId;
  final String songDataJson;
  final int downloadedBytes;
  final double progress;

  HivePausedDownload({
    required this.vId,
    required this.songDataJson,
    required this.downloadedBytes,
    required this.progress,
  });

  // Convenience: decode the stored JSON back into a Songmodel.
  Songmodel? get songData {
    try {
      return Songmodel.fromJson(
          jsonDecode(songDataJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class HivePausedDownloadAdapter extends TypeAdapter<HivePausedDownload> {
  @override
  final int typeId = 3;

  @override
  HivePausedDownload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePausedDownload(
      vId: fields[0] as String,
      songDataJson: fields[1] as String,
      downloadedBytes: fields[2] as int,
      progress: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, HivePausedDownload obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.vId)
      ..writeByte(1)
      ..write(obj.songDataJson)
      ..writeByte(2)
      ..write(obj.downloadedBytes)
      ..writeByte(3)
      ..write(obj.progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePausedDownloadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
