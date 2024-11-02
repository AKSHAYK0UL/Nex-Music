import 'package:dart_ytmusic_api/types.dart';

class Songmodel {
  final String vId;
  final String songName;
  final ArtistBasic artist;
  final String thumbnail;

  Songmodel({
    required this.vId,
    required this.songName,
    required this.artist,
    required this.thumbnail,
  });
}
