import 'dart:convert';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:http/http.dart' as http;
import 'package:nex_music/model/lyric_model.dart';

class LyricsNetworkProvider {
  final YTMusic _ytMusic;

  LyricsNetworkProvider({required YTMusic ytMusic}) : _ytMusic = ytMusic;

  static const String _lrclibBaseUrl = 'https://lrclib.net/api';
  static const String _ytMusicBaseUrl = 'https://music.youtube.com/youtubei/v1';

  static const Map<String, String> _headers = {
    'User-Agent': 'NexMusic/1.0',
  };

  static const Map<String, String> _ytMusicHeaders = {
    'Content-Type': 'application/json',
    'User-Agent':
        'com.google.android.apps.youtube.music/6.43.52 (Linux; U; Android 13; en_US)',
  };

  static const Map<String, dynamic> _ytMusicContext = {
    'client': {
      'clientName': 'ANDROID_MUSIC',
      'clientVersion': '6.43.52',
      'androidSdkVersion': 33,
      'hl': 'en',
    }
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

  // Fetches native time-synchronized lyrics directly from YouTube Music's InnerTube API.
  // Because it queries the exact videoId played on YouTube, timing is 100% matched to the audio stream.
  Future<LyricModel?> fetchYouTubeMusicLyrics(String videoId) async {
    if (videoId.trim().isEmpty) return null;
    try {
      //  Get next endpoint to resolve lyrics browseId
      final nextUri = Uri.parse('$_ytMusicBaseUrl/next?prettyPrint=false');
      final nextRes = await http
          .post(
            nextUri,
            headers: _ytMusicHeaders,
            body: jsonEncode({
              'context': _ytMusicContext,
              'videoId': videoId,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (nextRes.statusCode != 200) return null;

      final nextJson = jsonDecode(nextRes.body) as Map<String, dynamic>;
      final tabs = nextJson['contents']
              ?['singleColumnMusicWatchNextResultsRenderer']?['tabbedRenderer']
          ?['watchNextTabbedResultsRenderer']?['tabs'] as List?;

      String? lyricsBrowseId;
      if (tabs != null) {
        for (final tab in tabs) {
          final tabRenderer = tab['tabRenderer'];
          final endpoint = tabRenderer?['endpoint']?['browseEndpoint'];
          final bId = endpoint?['browseId'] as String?;
          if (bId != null && bId.startsWith('MPLY')) {
            lyricsBrowseId = bId;
            break;
          }
        }
      }

      if (lyricsBrowseId == null) return null;

      // Fetch lyrics details from browse endpoint
      final browseUri = Uri.parse('$_ytMusicBaseUrl/browse?prettyPrint=false');
      final browseRes = await http
          .post(
            browseUri,
            headers: _ytMusicHeaders,
            body: jsonEncode({
              'context': _ytMusicContext,
              'browseId': lyricsBrowseId,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (browseRes.statusCode != 200) return null;

      final browseJson = jsonDecode(browseRes.body) as Map<String, dynamic>;
      dynamic timedModel = browseJson['contents']?['elementRenderer']
              ?['newElement']?['type']?['componentType']?['model']
          ?['timedLyricsModel'];

      if (timedModel == null) {
        dynamic findTimed(dynamic node) {
          if (node is Map) {
            if (node.containsKey('timedLyricsModel')) {
              return node['timedLyricsModel'];
            }
            for (final v in node.values) {
              final r = findTimed(v);
              if (r != null) return r;
            }
          } else if (node is List) {
            for (final item in node) {
              final r = findTimed(item);
              if (r != null) return r;
            }
          }
          return null;
        }

        timedModel = findTimed(browseJson);
      }

      final lyricsData = timedModel?['lyricsData'];
      final rawLines = lyricsData?['timedLyricsData'] as List?;

      if (rawLines != null && rawLines.isNotEmpty) {
        final List<LyricLine> syncedLines = [];
        final List<String> plainLines = [];

        for (final item in rawLines) {
          final text = (item['lyricLine'] as String? ?? '').trim();
          final cueRange = item['cueRange'];

          if (cueRange != null) {
            final startMs = int.tryParse(
                cueRange['startTimeMilliseconds']?.toString() ?? '');
            final endMs =
                int.tryParse(cueRange['endTimeMilliseconds']?.toString() ?? '');
            if (startMs != null) {
              final startDuration = Duration(milliseconds: startMs);
              final endDuration =
                  endMs != null ? Duration(milliseconds: endMs) : null;
              syncedLines.add(
                LyricLine(
                  timestamp: startDuration,
                  endTime: endDuration,
                  text: text.isEmpty ? '♪' : text,
                ),
              );
            }
          }

          if (text.isNotEmpty && text != '♪') {
            plainLines.add(text);
          }
        }

        if (syncedLines.isNotEmpty) {
          return LyricModel(
            plainLyrics: plainLines.isNotEmpty
                ? plainLines.join('\n')
                : syncedLines.map((e) => e.text).join('\n'),
            syncedLyrics: syncedLines,
          );
        }

        if (plainLines.isNotEmpty) {
          return LyricModel(plainLyrics: plainLines.join('\n'));
        }
      }

      // Check description shelf fallback for plain lyrics
      final sectionList =
          browseJson['contents']?['sectionListRenderer']?['contents'] as List?;
      if (sectionList != null && sectionList.isNotEmpty) {
        final desc = sectionList[0]?['musicDescriptionShelfRenderer']
            ?['description']?['runs'] as List?;
        if (desc != null && desc.isNotEmpty) {
          final plainText = desc.map((r) => r['text'] ?? '').join('').trim();
          if (plainText.isNotEmpty) {
            return LyricModel(plainLyrics: plainText);
          }
        }
      }
    } catch (_) {}
    return null;
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

  // Fetches lyrics:
  // 1. First priority: YouTube Music official native timed lyrics (exact videoId or track search fallback).
  // 2. Second priority: LRCLIB synchronized lyrics (community LRC database).
  // 3. Fallback: YouTube Music plain text lyrics.
  Future<LyricModel?> fetchLyrics({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    LyricModel? ytFallbackLyrics;

    //  YouTube Music Official API: Try native timed lyrics directly with played videoId first
    if (videoId.trim().isNotEmpty) {
      try {
        final ytLyrics = await fetchYouTubeMusicLyrics(videoId);
        if (ytLyrics != null) {
          if (ytLyrics.hasSyncedLyrics) {
            return ytLyrics;
          }
          ytFallbackLyrics = ytLyrics;
        }
      } catch (_) {}
    }

    final cleanedTitle = cleanTitle(title);
    final cleanedArtist = cleanArtist(artist);
    final primary = primaryArtist(artist);

    //  YouTube Music Track Search: If played videoId has no cueRange timed lyrics
    // (e.g. it is an official music video or static layout), search YouTube Music for the official track version.
    // Official tracks on YouTube Music almost always have official cueRange timed lyrics!
    try {
      await _ytMusic.initialize();
      List<dynamic> searchCandidates = [];
      try {
        searchCandidates = await _ytMusic
            .searchSongs('$cleanedTitle $primary')
            .timeout(const Duration(seconds: 4));
      } catch (_) {}

      if (searchCandidates.isEmpty) {
        try {
          searchCandidates = await _ytMusic
              .searchSongs(cleanedTitle)
              .timeout(const Duration(seconds: 4));
        } catch (_) {}
      }

      if (searchCandidates.isNotEmpty) {
        final candidatesList = searchCandidates.toList();
        if (durationSeconds != null && durationSeconds > 0) {
          candidatesList.sort((a, b) {
            final aDur = (a.duration as num?)?.toInt() ?? 0;
            final bDur = (b.duration as num?)?.toInt() ?? 0;
            final aDiff = aDur > 0 ? (aDur - durationSeconds).abs() : 999;
            final bDiff = bDur > 0 ? (bDur - durationSeconds).abs() : 999;
            return aDiff.compareTo(bDiff);
          });
        }

        for (final candidate in candidatesList.take(3)) {
          final candVideoId = candidate.videoId as String?;
          if (candVideoId == null || candVideoId == videoId) continue;
          try {
            final candidateLyrics = await fetchYouTubeMusicLyrics(candVideoId);
            if (candidateLyrics != null && candidateLyrics.hasSyncedLyrics) {
              return candidateLyrics;
            }
            if (ytFallbackLyrics == null &&
                candidateLyrics != null &&
                candidateLyrics.hasLyrics) {
              ytFallbackLyrics = candidateLyrics;
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    // Try LRCLIB exact get
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
        // Continue to search
      }
    }

    // Try LRCLIB search endpoint
    List<dynamic> searchResults = [];
    try {
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

    //  Fallback to YouTube Music plain text lyrics if obtained earlier
    if (ytFallbackLyrics != null && ytFallbackLyrics.hasLyrics) {
      return ytFallbackLyrics;
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
      // Failed
    }

    return null;
  }
}
