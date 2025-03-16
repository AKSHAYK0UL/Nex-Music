import 'package:http/http.dart' as http;

import 'package:dart_ytmusic_api/types.dart';

String getThumbnail(List<ThumbnailFull> thumbnails) {
  String thumbnail = thumbnails.last.url;
  return thumbnail;
}

Future<String> getThumbnailUsingUrl(String videoId) async {
  // List of resolutions in preferred order.
  final List<String> resolutions = [
    'maxresdefault.jpg',
    'hqdefault.jpg',
    'mqdefault.jpg',
    'sddefault.jpg'
  ];

  for (final res in resolutions) {
    final url = 'https://i.ytimg.com/vi/$videoId/$res';
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        // Return the first URL that is available.
        return url;
      }
    } catch (e) {
      // If an exception occurs, we continue to the next resolution.
      continue;
    }
  }

  // Fallback: if none of the resolutions are available, return a default thumbnail.
  return 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
}
