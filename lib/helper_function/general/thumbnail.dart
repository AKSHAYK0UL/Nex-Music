import 'package:dart_ytmusic_api/types.dart';

String getThumbnail(List<ThumbnailFull> thumbnails) {
  if (thumbnails.length > 2 && thumbnails[2].url.isNotEmpty) {
    return thumbnails[2].url;
  } else if (thumbnails.length > 1 && thumbnails[1].url.isNotEmpty) {
    return thumbnails[1].url;
  }
  return thumbnails[0].url;
}
