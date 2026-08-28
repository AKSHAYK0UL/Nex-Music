import 'dart:async';
import 'dart:convert';
import 'dart:io';
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





//############ updated
Future<List<String>> _fetchAllVideoIds({
  required String playlistId,
  required String apiKey,
}) async {
  const baseUrl = 'https://www.googleapis.com/youtube/v3/playlistItems';
  const maxRetries = 4;
  const requestTimeout = Duration(seconds: 15);
  const maxPages = 500; //safety net

  final isMix = playlistId.startsWith('RD');
  print('[fetchAllVideoIds] START playlistId=$playlistId type=${isMix ? "MIX/RADIO" : "NORMAL"}');

  final ids = <String>[];
  final seenIds = <String>{};       // dedupe video IDs
  final seenTokens = <String>{};    // detect repeating pageTokens (the actual bug)
  String? pageToken;
  var pageCount = 0;

  do {
    pageCount++;

    // Cycle detection: if we've already used this exact pageToken before,
    // the API is looping (this is what happens on Mix/Radio playlists)
    if (pageToken != null && seenTokens.contains(pageToken)) {
      print('[fetchAllVideoIds] CYCLE DETECTED at page=$pageCount — pageToken repeated. '
          'Likely a Mix/Radio playlist (isMix=$isMix). Stopping pagination.');
      break;
    }
    if (pageToken != null) seenTokens.add(pageToken);

    final params = {
      'part': 'contentDetails',
      'playlistId': playlistId,
      'maxResults': '50',
      'key': apiKey,
      if (pageToken != null) 'pageToken': pageToken,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    print('[fetchAllVideoIds] page=$pageCount pageToken=${pageToken ?? "(first)"}');

    Map<String, dynamic>? body;
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        final response = await http.get(uri).timeout(requestTimeout);

        if (response.statusCode == 429 ||
            (response.statusCode >= 500 && response.statusCode < 600)) {
          print('[fetchAllVideoIds] page=$pageCount attempt=$attempt TRANSIENT ${response.statusCode}');
          throw http.ClientException('Transient HTTP ${response.statusCode}');
        }

        _assertOk(response, 'playlistItems.list');
        body = jsonDecode(response.body) as Map<String, dynamic>;
        print('[fetchAllVideoIds] page=$pageCount attempt=$attempt SUCCESS');
        break;
      } on TimeoutException catch (e) {
        print('[fetchAllVideoIds] page=$pageCount attempt=$attempt TIMEOUT: $e');
        if (attempt > maxRetries) rethrow;
      } on SocketException catch (e) {
        print('[fetchAllVideoIds] page=$pageCount attempt=$attempt SOCKET ERROR: $e');
        if (attempt > maxRetries) rethrow;
      } on http.ClientException catch (e) {
        print('[fetchAllVideoIds] page=$pageCount attempt=$attempt CLIENT EXCEPTION: $e');
        if (attempt > maxRetries) rethrow;
      } on FormatException catch (e) {
        print('[fetchAllVideoIds] page=$pageCount attempt=$attempt MALFORMED JSON: $e');
        if (attempt > maxRetries) rethrow;
      }

      final delayMs = 500 * (1 << (attempt - 1));
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    final items = body['items'] as List<dynamic>? ?? [];
    var newOnThisPage = 0;
    for (final item in items) {
      final videoId = (item['contentDetails']
          as Map<String, dynamic>?)?['videoId'] as String?;
      if (videoId != null && videoId.isNotEmpty && seenIds.add(videoId)) {
        ids.add(videoId);
        newOnThisPage++;
      }
    }

    //  if tokens didn't repeat, if a
    // full page came back with zero new video IDs, we're looping .
    if (items.isNotEmpty && newOnThisPage == 0) {
      print('[fetchAllVideoIds] page=$pageCount returned only already-seen IDs — stopping.');
      break;
    }

    pageToken = body['nextPageToken'] as String?;
    print('[fetchAllVideoIds] page=$pageCount done, newIds=$newOnThisPage, runningTotal=${ids.length}');
  } while (pageToken != null && pageCount < maxPages);

  print('[fetchAllVideoIds] DONE playlistId=$playlistId totalIds=${ids.length} pagesFetched=$pageCount');
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

