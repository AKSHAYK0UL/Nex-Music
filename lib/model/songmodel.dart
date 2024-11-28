import 'package:dart_ytmusic_api/types.dart';
import 'package:equatable/equatable.dart';

class Songmodel extends Equatable {
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

  Map<String, dynamic> toJson() {
    return {
      "v_id": vId,
      "song_name": songName,
      "artist": {"artist_name": artist.name, "artist_id": artist.artistId},
      "thumbnail": thumbnail,
      "duration": duration,
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
  List<Object?> get props => [vId, songName, artist, thumbnail, duration];
}
