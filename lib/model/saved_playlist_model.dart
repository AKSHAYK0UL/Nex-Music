import 'package:dart_ytmusic_api/types.dart';

class SavedPlaylistModel {
  final String playListId;
  final String playlistName;
  final ArtistBasic artistBasic;
  final String thumbnail;
  final bool isAlbum;
  final dynamic timestamp;

  SavedPlaylistModel({
    required this.playListId,
    required this.playlistName,
    required this.artistBasic,
    required this.thumbnail,
    required this.isAlbum,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playListId,
      'playlist_name': playlistName,
      'artist_name': artistBasic.name,
      'artist_id': artistBasic.artistId,
      'thumbnail': thumbnail,
      'is_album': isAlbum,
    };
  }

  factory SavedPlaylistModel.fromJson(Map<String, dynamic> json) {
    return SavedPlaylistModel(
      playListId: json['playlist_id'] ?? '',
      playlistName: json['playlist_name'] ?? '',
      artistBasic: ArtistBasic(
        name: json['artist_name'] ?? '',
        artistId: json['artist_id'],
      ),
      thumbnail: json['thumbnail'] ?? '',
      isAlbum: json['is_album'] ?? false,
      timestamp: json['timestamp'],
    );
  }
}
