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
    var cleaned = title
        .replaceAll(
          RegExp(
            r'\s*[\(\[](?:official\s*(?:music\s*)?video|official\s*audio|official|lyrics?|lyric\s*video|audio|video|visualizer|full\s*(?:song|video|audio)|hd|4k|remastered|slowed\s*\+\s*reverb|slowed|reverb|sped\s*up|feat\.?|ft\.?|prod\.?)[^\)\]]*[\)\]]',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'\s*[\(\[](?:from\s+"[^"]+"|from\s+[\w\s]+)[\)\]]',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'-\s*(?:official\s*)?(?:audio|video|lyrics?|visualizer).*$',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\|.*$'), '')
        .replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '')
        .replaceAll(RegExp('["\'״“”‘’]'), '')
        .trim();

    // If title has "Artist, Track", extract the track part if available
    if (cleaned.contains(' - ')) {
      final parts = cleaned.split(' - ');
      if (parts.length == 2 && parts[1].trim().isNotEmpty) {
        cleaned = parts[1].trim();
      }
    }

    return cleaned;
  }

  // Clean artist string (e.g. "ABC - Topic" -> "ABC")
  static String cleanArtist(String artist) {
    return artist
        .replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '')
        .replaceAll(RegExp(r'VEVO$', caseSensitive: false), '')
        .trim();
  }

  // Extract primary artist (e.g. "ABC, XYZ" -> "ABC")
  static String primaryArtist(String artist) {
    final cleaned = cleanArtist(artist);
    final split =
        cleaned.split(RegExp(r'[,&/]|\bfeat\.?\b', caseSensitive: false));
    return split.first.trim();
  }

  // Finds the best candidate item from LRCLIB search results based on duration and title match
  static Map<String, dynamic>? _findBestCandidate({
    required List<dynamic> results,
    required String targetTitle,
    required String targetArtist,
    int? durationSeconds,
  }) {
    if (results.isEmpty) return null;

    Map<String, dynamic>? bestItem;
    int bestScore = -9999;

    for (final raw in results) {
      if (raw is! Map<String, dynamic>) continue;
      final item = raw;

      final synced = item['syncedLyrics'] as String?;
      final plain = item['plainLyrics'] as String?;
      final hasSynced = synced != null && synced.trim().isNotEmpty;
      final hasPlain = plain != null && plain.trim().isNotEmpty;

      if (!hasSynced && !hasPlain) continue;

      int score = 0;

      // Prefer synced lyrics
      if (hasSynced) score += 60;

      // Duration comparison (essential for accurate synchronization)
      final itemDuration = (item['duration'] as num?)?.round();
      if (durationSeconds != null &&
          durationSeconds > 0 &&
          itemDuration != null) {
        final diff = (itemDuration - durationSeconds).abs();
        if (diff <= 2) {
          score += 150; // exact match
        } else if (diff <= 5) {
          score += 100; // very close (start/end silence difference)
        } else if (diff <= 10) {
          score += 50;
        } else if (diff <= 18) {
          score += 10;
        } else if (diff > 30) {
          score -= 100; // likely a live version, remix, or spoken intro
        } else if (diff > 60) {
          score -= 200; // completely different cut
        }
      }

      // Track title similarity
      final trackName =
          (item['trackName'] as String? ?? '').toLowerCase().trim();
      final normTargetTitle = targetTitle.toLowerCase().trim();
      if (trackName == normTargetTitle) {
        score += 60;
      } else if (trackName.contains(normTargetTitle) ||
          normTargetTitle.contains(trackName)) {
        score += 30;
      }

      // Artist similarity
      final artistName =
          (item['artistName'] as String? ?? '').toLowerCase().trim();
      final normTargetArtist = targetArtist.toLowerCase().trim();
      if (artistName.isNotEmpty && normTargetArtist.isNotEmpty) {
        if (artistName == normTargetArtist) {
          score += 40;
        } else if (artistName.contains(normTargetArtist) ||
            normTargetArtist.contains(artistName)) {
          score += 25;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestItem = item;
      }
    }

    return bestItem;
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
    final primary = primaryArtist(artist);

    //  Try LRCLIB exact get
    for (final artistQuery in [primary, cleanedArtist]) {
      try {
        final queryParams = <String, String>{
          'track_name': cleanedTitle,
          'artist_name': artistQuery,
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

          final syncedLines = syncedStr != null
              ? LyricModel.parseLrc(syncedStr)
              : <LyricLine>[];

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
        // Continue
      }
    }

    //  Try LRCLIB search endpoint (both structured search and general query)
    List<dynamic> searchResults = [];
    try {
      // Structured search with track_name and artist_name
      final structuredUri = Uri.parse('$_lrclibBaseUrl/search').replace(
        queryParameters: {
          'track_name': cleanedTitle,
          'artist_name': primary,
        },
      );
      final structRes =
          await http.get(structuredUri, headers: _headers).timeout(
                const Duration(seconds: 4),
              );

      if (structRes.statusCode == 200) {
        searchResults = jsonDecode(structRes.body) as List<dynamic>;
      }
    } catch (_) {}

    if (searchResults.isEmpty) {
      try {
        // Fallback to text search
        final searchUri = Uri.parse('$_lrclibBaseUrl/search').replace(
          queryParameters: {
            'q': '$cleanedTitle $primary',
          },
        );
        final searchRes = await http.get(searchUri, headers: _headers).timeout(
              const Duration(seconds: 4),
            );

        if (searchRes.statusCode == 200) {
          searchResults = jsonDecode(searchRes.body) as List<dynamic>;
        }
      } catch (_) {}
    }

    if (searchResults.isNotEmpty) {
      final bestCandidate = _findBestCandidate(
        results: searchResults,
        targetTitle: cleanedTitle,
        targetArtist: primary,
        durationSeconds: durationSeconds,
      );

      if (bestCandidate != null) {
        final syncedStr = bestCandidate['syncedLyrics'] as String?;
        final plainStr = bestCandidate['plainLyrics'] as String?;
        final candidateDuration = (bestCandidate['duration'] as num?)?.round();

        // If duration difference is extreme (> 25s), avoid out-of-sync timestamps
        final durationDiff = (durationSeconds != null &&
                durationSeconds > 0 &&
                candidateDuration != null)
            ? (candidateDuration - durationSeconds).abs()
            : 0;

        if (syncedStr != null &&
            syncedStr.trim().isNotEmpty &&
            durationDiff <= 25) {
          final syncedLines = LyricModel.parseLrc(syncedStr);
          if (syncedLines.isNotEmpty) {
            return LyricModel(
              plainLyrics:
                  plainStr ?? syncedLines.map((e) => e.text).join('\n'),
              syncedLyrics: syncedLines,
            );
          }
        }

        if (plainStr != null && plainStr.trim().isNotEmpty) {
          return LyricModel(plainLyrics: plainStr);
        }
      }
    }

    //  Fallback to dart_ytmusic_api official lyrics
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
