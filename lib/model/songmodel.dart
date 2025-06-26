import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:equatable/equatable.dart';

// class Songmodel extends Equatable {
//   final String vId;
//   final String songName;
//   final ArtistBasic artist;
//   final String thumbnail;
//   final String duration;
//   final Timestamp? timestamp;

//   const Songmodel({
//     required this.vId,
//     required this.songName,
//     required this.artist,
//     required this.thumbnail,
//     required this.duration,
//     this.timestamp,
//   });

//   // factory Songmodel.fromJson(Map<String, dynamic> json) {
//   //   return Songmodel(
//   //     vId: json["v_id"],
//   //     songName: json["song_name"],
//   //     artist: ArtistBasic.fromMap(json["artist"]),
//   //     thumbnail: json["thumbnail"],
//   //     duration: json["duration"],
//   //     timestamp:
//   //         json["timestamp"] != null ? json["timestamp"] as Timestamp : null,
//   //   );
//   // }

//   factory Songmodel.fromJson(Map<String, dynamic> json) {
//     Timestamp? ts;
//     if (json["timestamp"] != null) {
//       if (json["timestamp"] is String) {
//         ts = Timestamp.fromDate(DateTime.parse(json["timestamp"]));
//       } else if (json["timestamp"] is Timestamp) {
//         ts = json["timestamp"];
//       }
//     }

//     return Songmodel(
//       vId: json["v_id"],
//       songName: json["song_name"],
//       artist: ArtistBasic.fromMap(json["artist"]),
//       thumbnail: json["thumbnail"],
//       duration: json["duration"],
//       timestamp: ts,
//     );
//   }

//   // Map<String, dynamic> toJson() {
//   //   return {
//   //     "v_id": vId,
//   //     "song_name": songName,
//   //     "artist": {"name": artist.name, "artistId": artist.artistId},
//   //     "thumbnail": thumbnail,
//   //     "duration": duration,
//   //     "timestamp": timestamp,
//   //   };
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       "v_id": vId,
//       "song_name": songName,
//       "artist": {"name": artist.name, "artistId": artist.artistId},
//       "thumbnail": thumbnail,
//       "duration": duration,
//       "timestamp": timestamp?.toDate().toIso8601String(),
//     };
//   }

//   Songmodel copyWith({
//     String? vId,
//     String? songName,
//     ArtistBasic? artist,
//     String? thumbnail,
//     String? duration,
//   }) {
//     return Songmodel(
//       vId: vId ?? this.vId,
//       songName: songName ?? this.songName,
//       artist: artist ?? this.artist,
//       thumbnail: thumbnail ?? this.thumbnail,
//       duration: duration ?? this.duration,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     vId,
//     songName,
//     artist,
//     thumbnail,
//     duration,
//     timestamp,
//   ];
// }

class Songmodel extends Equatable {
  final String vId;
  final String songName;
  final ArtistBasic artist;
  final String thumbnail;
  final String duration;
  final Timestamp? timestamp;

  final bool isLocal;
  final String? localFilePath;
  final String? audioFormat;

  const Songmodel({
    required this.vId,
    required this.songName,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    this.timestamp,
    this.isLocal = false,
    this.localFilePath,
    this.audioFormat,
  });

  factory Songmodel.fromJson(Map<String, dynamic> json) {
    Timestamp? ts;
    if (json["timestamp"] != null) {
      if (json["timestamp"] is String) {
        ts = Timestamp.fromDate(DateTime.parse(json["timestamp"]));
      } else if (json["timestamp"] is Timestamp) {
        ts = json["timestamp"];
      }
    }

    return Songmodel(
        vId: json["v_id"],
        songName: json["song_name"],
        artist: ArtistBasic.fromMap(json["artist"]),
        thumbnail: json["thumbnail"],
        duration: json["duration"],
        timestamp: ts,
        isLocal: json["isLocal"] ?? false,
        localFilePath: json["localFilePath"],
        audioFormat: json["audioformat"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "v_id": vId,
      "song_name": songName,
      "artist": {"name": artist.name, "artistId": artist.artistId},
      "thumbnail": thumbnail,
      "duration": duration,
      "timestamp": timestamp?.toDate().toIso8601String(),
      "isLocal": isLocal,
      "localFilePath": localFilePath,
      "audioformat": audioFormat,
    };
  }

  Map<String, dynamic> toJsonTHINK() {
    return {
      "song_name": songName,
      "artist": artist.name,
    };
  }

  Songmodel copyWith({
    String? vId,
    String? songName,
    ArtistBasic? artist,
    String? thumbnail,
    String? duration,
    Timestamp? timestamp,
    bool? isLocal,
    String? localFilePath,
    String? audioFormat,
  }) {
    return Songmodel(
      vId: vId ?? this.vId,
      songName: songName ?? this.songName,
      artist: artist ?? this.artist,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      isLocal: isLocal ?? this.isLocal,
      localFilePath: localFilePath ?? this.localFilePath,
      audioFormat: audioFormat ?? this.audioFormat,
    );
  }

  @override
  List<Object?> get props => [
        vId,
        songName,
        artist,
        thumbnail,
        duration,
        timestamp,
        isLocal,
        localFilePath,
        audioFormat,
      ];
}
