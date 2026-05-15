import 'package:dart_ytmusic_api/types.dart';

class ArtistModel {
  final ArtistBasic artist;
  final String thumbnail;
  final dynamic timestamp;

  ArtistModel({
    required this.artist,
    required this.thumbnail,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "artist_id": artist.artistId,
      "artist_name": artist.name,
      "thumbnail": thumbnail,
      "timestamp": timestamp,
    };
  }

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      artist: ArtistBasic(
        name: json["artist_name"],
        artistId: json["artist_id"],
      ),
      thumbnail: json["thumbnail"],
      timestamp: json["timestamp"],
    );
  }
}
