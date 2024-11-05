import 'package:dart_ytmusic_api/types.dart';

class Songmodel {
  final String vId;
  final String songName;
  final ArtistBasic artist;
  final String thumbnail;
  final String duration;

  Songmodel({
    required this.vId,
    required this.songName,
    required this.artist,
    required this.thumbnail,
    required this.duration,
  });

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
}
