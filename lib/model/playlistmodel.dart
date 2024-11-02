import 'package:dart_ytmusic_api/types.dart';

class PlayListmodel {
  final String playListId;
  final String playlistName;
  final ArtistBasic artistBasic;
  final String thumbnail;

  PlayListmodel({
    required this.playListId,
    required this.playlistName,
    required this.artistBasic,
    required this.thumbnail,
  });
}
