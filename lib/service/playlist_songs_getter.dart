import 'dart:convert';
import 'package:http/http.dart' as http;

// Model

class VideoMetadata {
  final String videoId;
  final Duration duration;

  const VideoMetadata({
    required this.videoId,
    required this.duration,
  });

  @override
  String toString() =>
      'VideoMetadata(id: $videoId, duration: ${_formatDuration(duration)})';

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}


Future<List<VideoMetadata>> fetchPlaylistVideoMetadata({
  required String playlistId,
  required String apiKey,
}) async {
  final videoIds = await _fetchAllVideoIds(
    playlistId: playlistId,
    apiKey: apiKey,
  );

  if (videoIds.isEmpty) return [];

  return _fetchDurationsForVideoIds(
    videoIds: videoIds,
    apiKey: apiKey,
  );
}



Future<List<String>> _fetchAllVideoIds({
  required String playlistId,
  required String apiKey,
}) async {
  const baseUrl = 'https://www.googleapis.com/youtube/v3/playlistItems';

  final ids = <String>[];
  String? pageToken;

  do {
    final params = {
      'part': 'contentDetails',   // only contentDetails needed for video IDs
      'playlistId': playlistId,
      'maxResults': '50',         // max allowed per request
      'key': apiKey,
      if (pageToken != null) 'pageToken': pageToken,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    _assertOk(response, 'playlistItems.list');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];

    for (final item in items) {
      final videoId = (item['contentDetails'] as Map<String, dynamic>?)?['videoId'] as String?;
      // Skip deleted / private videos (videoId will be null or empty)
      if (videoId != null && videoId.isNotEmpty) {
        ids.add(videoId);
      }
    }

    // Move to next page, or null ->done
    pageToken = body['nextPageToken'] as String?;
  } while (pageToken != null);

  return ids;
}



Future<List<VideoMetadata>> _fetchDurationsForVideoIds({
  required List<String> videoIds,
  required String apiKey,
}) async {
  const baseUrl = 'https://www.googleapis.com/youtube/v3/videos';
  const batchSize = 50;

  final results = <VideoMetadata>[];

  for (var i = 0; i < videoIds.length; i += batchSize) {
    final batch = videoIds.sublist(
      i,
      (i + batchSize).clamp(0, videoIds.length),
    );

    final params = {
      'part': 'contentDetails',
      'id': batch.join(','),
      'key': apiKey,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    _assertOk(response, 'videos.list');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];

    for (final item in items) {
      final id = item['id'] as String;
      final rawDuration =
          (item['contentDetails'] as Map<String, dynamic>?)?['duration'] as String?;

      results.add(VideoMetadata(
        videoId: id,
        duration: rawDuration != null ? _parseIso8601Duration(rawDuration) : Duration.zero,
      ));
    }
  }

  return results;
}



Duration _parseIso8601Duration(String raw) {
  // Regex covers hours, minutes, seconds (weeks/days rarely appear but handled)
  final match = RegExp(
    r'P(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?',
  ).firstMatch(raw);

  if (match == null) return Duration.zero;

  final weeks   = int.tryParse(match.group(1) ?? '') ?? 0;
  final days    = int.tryParse(match.group(2) ?? '') ?? 0;
  final hours   = int.tryParse(match.group(3) ?? '') ?? 0;
  final minutes = int.tryParse(match.group(4) ?? '') ?? 0;
  final seconds = int.tryParse(match.group(5) ?? '') ?? 0;

  return Duration(
    days:    weeks * 7 + days,
    hours:   hours,
    minutes: minutes,
    seconds: seconds,
  );
}

// Error handling


void _assertOk(http.Response response, String endpoint) {
  if (response.statusCode != 200) {
    throw YouTubeApiException(
      endpoint: endpoint,
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class YouTubeApiException implements Exception {
  final String endpoint;
  final int statusCode;
  final String body;

  const YouTubeApiException({
    required this.endpoint,
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() =>
      'YouTubeApiException[$endpoint]: HTTP $statusCode\n$body';
}

