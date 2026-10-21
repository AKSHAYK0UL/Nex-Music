import 'dart:convert';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:http/http.dart' as http;
import 'package:nex_music/model/lyric_model.dart';

class LyricsNetworkProvider {
  final YTMusic _ytMusic;

  LyricsNetworkProvider({required YTMusic ytMusic}) : _ytMusic = ytMusic;

  static const String _lrclibBaseUrl = 'https://lrclib.net/api';
  static const Map<String, String> _headers = {
    'User-Agent': 'NexMusic/1.0',
  };

  // Clean title of common metadata noise like "(Official Video)", "ft. Artist", etc.
  static String cleanTitle(String title) {
    return title
        .replaceAll(
          RegExp(
            r'\(.*?(official|video|audio|lyrics?|feat|ft\.|prod\.).*?\)',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'\[.*?(official|video|audio|lyrics?|feat|ft\.|prod\.).*?\]',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\|.*$'), '')
        .trim();
  }

  // Clean artist string (e.g. "The Weeknd - Topic" -> "The Weeknd")
  static String cleanArtist(String artist) {
    return artist
        .replaceAll(RegExp(r' - Topic$', caseSensitive: false), '')
        .replaceAll(RegExp(r'VEVO$', caseSensitive: false), '')
        .trim();
  }

  // Fetches lyrics, prioritizing LRCLIB for synced lyrics, and falling back to dart_ytmusic_api.
  Future<LyricModel?> fetchLyrics({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    final cleanedTitle = cleanTitle(title);
    final cleanedArtist = cleanArtist(artist);

    // Try LRCLIB exact get
    try {
      final queryParams = <String, String>{
        'track_name': cleanedTitle,
        'artist_name': cleanedArtist,
      };
      if (durationSeconds != null && durationSeconds > 0) {
        queryParams['duration'] = durationSeconds.toString();
      }

      final uri = Uri.parse('$_lrclibBaseUrl/get')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final syncedStr = data['syncedLyrics'] as String?;
        final plainStr = data['plainLyrics'] as String?;

        final syncedLines =
            syncedStr != null ? LyricModel.parseLrc(syncedStr) : <LyricLine>[];

        if (syncedLines.isNotEmpty ||
            (plainStr != null && plainStr.trim().isNotEmpty)) {
          return LyricModel(
            plainLyrics:
                plainStr ?? (syncedLines.map((e) => e.text).join('\n')),
            syncedLyrics: syncedLines,
          );
        }
      }
    } catch (_) {
      // Continue to search / fallback
    }

    // Try LRCLIB search endpoint
    try {
      final searchUri = Uri.parse('$_lrclibBaseUrl/search').replace(
        queryParameters: {
          'q': '$cleanedTitle $cleanedArtist',
        },
      );
      final searchRes = await http.get(searchUri, headers: _headers).timeout(
            const Duration(seconds: 4),
          );

      if (searchRes.statusCode == 200) {
        final results = jsonDecode(searchRes.body) as List<dynamic>;
        if (results.isNotEmpty) {
          // Find first entry with syncedLyrics or plainLyrics
          for (final item in results) {
            final syncedStr = item['syncedLyrics'] as String?;
            final plainStr = item['plainLyrics'] as String?;

            if (syncedStr != null && syncedStr.trim().isNotEmpty) {
              final syncedLines = LyricModel.parseLrc(syncedStr);
              return LyricModel(
                plainLyrics:
                    plainStr ?? syncedLines.map((e) => e.text).join('\n'),
                syncedLyrics: syncedLines,
              );
            }
          }

          // If no synced, use first with plain lyrics
          for (final item in results) {
            final plainStr = item['plainLyrics'] as String?;
            if (plainStr != null && plainStr.trim().isNotEmpty) {
              return LyricModel(plainLyrics: plainStr);
            }
          }
        }
      }
    } catch (_) {
      // Continue to ytMusic fallback
    }

    // Fallback to dart_ytmusic_api official lyrics
    try {
      await _ytMusic.initialize();
      final ytLyrics = await _ytMusic.getLyrics(videoId).timeout(
            const Duration(seconds: 5),
          );

      if (ytLyrics != null && ytLyrics.trim().isNotEmpty) {
        return LyricModel(plainLyrics: ytLyrics);
      }
    } catch (_) {
      // Both failed
    }

    return null;
  }
}
