import 'package:dart_ytmusic_api/types.dart';

String getThumbnail(List<ThumbnailFull> thumbnails) {
  final len = thumbnails.length;
  print("Thumbnails URL :-> ${thumbnails[len - 1].url}");
  String thumbnail = thumbnails.last.url;
  return thumbnail;
}
