import 'package:dart_ytmusic_api/types.dart';
import 'package:http/http.dart' as http;
import 'package:nex_music/enum/quality.dart';

// Get thumbnail from YouTube Music API thumbnails list according to quality setting.
String getThumbnail(List<ThumbnailFull> thumbnails,
    [ThumbnailQuality? quality]) {
  if (thumbnails.isEmpty) return '';
  if (thumbnails.length == 1) return thumbnails.first.url;

  if (quality == ThumbnailQuality.low) {
    return thumbnails.first.url;
  } else if (quality == ThumbnailQuality.medium) {
    return thumbnails.length >= 3
        ? thumbnails[thumbnails.length - 2].url
        : thumbnails.first.url;
  }
  return thumbnails.last.url;
}

// Dynamically upgrades a thumbnail URL to high resolution for player screens and lockscreen.
// Maintains identical crop flags and aspect ratio so the image fit never changes or jumps.
String getHighResThumbnail(
  String url, {
  String? videoId,
  ThumbnailQuality? quality,
}) {
  if (url.isEmpty) {
    if (videoId != null && videoId.isNotEmpty) {
      return quality == ThumbnailQuality.low
          ? 'https://i.ytimg.com/vi/$videoId/mqdefault.jpg'
          : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
    }
    return url;
  }

  // If user chose Low quality in settings, keep original URL
  if (quality == ThumbnailQuality.low) {
    return url;
  }

  // 1 Google CDN thumbnails (lh3.googleusercontent.com, yt3.ggpht.com, etc.)
  // Official album covers and artist images
  if (url.contains('googleusercontent.com') || url.contains('ggpht.com')) {
    final targetDim = quality == ThumbnailQuality.medium ? 544 : 1000;
    String upgraded = url;

    // Update width parameter (e.g. =w120 -> =w1000, =w544 -> =w1000)
    if (upgraded.contains(RegExp(r'=w\d+'))) {
      upgraded = upgraded.replaceAllMapped(
        RegExp(r'=w\d+'),
        (match) => '=w$targetDim',
      );
    } else if (upgraded.contains(RegExp(r'-w\d+'))) {
      upgraded = upgraded.replaceAllMapped(
        RegExp(r'-w\d+'),
        (match) => '-w$targetDim',
      );
    }

    // Update height parameter (e.g. -h120 -> -h1000, -h544 -> -h1000)
    if (upgraded.contains(RegExp(r'-h\d+'))) {
      upgraded = upgraded.replaceAllMapped(
        RegExp(r'-h\d+'),
        (match) => '-h$targetDim',
      );
    }

    // Update size parameter (e.g. =s120 -> =s1000, =s544 -> =s1000)
    if (upgraded.contains(RegExp(r'=s\d+'))) {
      upgraded = upgraded.replaceAllMapped(
        RegExp(r'=s\d+'),
        (match) => '=s$targetDim',
      );
    }

    return upgraded;
  }

  // YouTube video thumbnails (i.ytimg.com)
  // remain identical between lists and the player, preventing any fit changes.
  return url;
}

// Fallback  kept for backward compatibility.
Future<String> getThumbnailUsingUrl(String videoId) async {
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
        return url;
      }
    } catch (_) {
      continue;
    }
  }

  return 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
}
