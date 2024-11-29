import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:equatable/equatable.dart';

class Songmodel extends Equatable {
  final String vId;
  final String songName;
  final ArtistBasic artist;
  final String thumbnail;
  final String duration;
  final Timestamp? timestamp;

  Songmodel({
    required this.vId,
    required this.songName,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    this.timestamp,
  });

  factory Songmodel.fromJson(Map<String, dynamic> json) {
    return Songmodel(
      vId: json["v_id"],
      songName: json["song_name"],
      artist: ArtistBasic.fromMap(json["artist"]),
      thumbnail: json["thumbnail"],
      duration: json["duration"],
      timestamp:
          json["timestamp"] != null ? json["timestamp"] as Timestamp : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "v_id": vId,
      "song_name": songName,
      "artist": {"name": artist.name, "artistId": artist.artistId},
      "thumbnail": thumbnail,
      "duration": duration,
      "timestamp": timestamp,
    };
  }

  Songmodel copyWith({
    String? vId,
    String? songName,
    ArtistBasic? artist,
    String? thumbnail,
    String? duration,
  }) {
    return Songmodel(
      vId: vId ?? this.vId,
      songName: songName ?? this.songName,
      artist: artist ?? this.artist,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props =>
      [vId, songName, artist, thumbnail, duration, timestamp];
}
