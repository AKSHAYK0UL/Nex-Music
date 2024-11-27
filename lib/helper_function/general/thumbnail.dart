import 'package:dart_ytmusic_api/types.dart';

String getThumbnail(List<ThumbnailFull> thumbnails) {
  String thumbnail = thumbnails.last.url;
  return thumbnail;
}
