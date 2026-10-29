import 'package:equatable/equatable.dart';

class LyricLine extends Equatable {
  final Duration timestamp;
  final Duration? endTime;
  final String text;

  const LyricLine({
    required this.timestamp,
    this.endTime,
    required this.text,
  });

  LyricLine copyWith({
    Duration? timestamp,
    Duration? endTime,
    String? text,
  }) {
    return LyricLine(
      timestamp: timestamp ?? this.timestamp,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [timestamp, endTime, text];
}

class LyricModel extends Equatable {
  final String? plainLyrics;
  final List<LyricLine> syncedLyrics;

  const LyricModel({
    this.plainLyrics,
    this.syncedLyrics = const [],
  });

  bool get hasSyncedLyrics => syncedLyrics.isNotEmpty;

  bool get hasLyrics =>
      (plainLyrics != null && plainLyrics!.trim().isNotEmpty) ||
      syncedLyrics.isNotEmpty;

  // Parses standard LRC format lyrics into a sorted list of [LyricLine].
  static List<LyricLine> parseLrc(String lrcContent) {
    if (lrcContent.trim().isEmpty) return const [];

    final List<LyricLine> rawLines = [];

    // Parse [offset:+/-ms] tag if present
    int offsetMs = 0;
    final offsetMatch = RegExp(
      r'\[offset:\s*([+-]?\d+)\s*\]',
      caseSensitive: false,
    ).firstMatch(lrcContent);
    if (offsetMatch != null) {
      offsetMs = int.tryParse(offsetMatch.group(1) ?? '0') ?? 0;
    }

    final timestampRegex = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');

    bool isCreditOrMetadata(String lineText, Duration lineDuration) {
      if (lineText.isEmpty) return false;
      final trimmed = lineText.trim();

      // Skip non-lyric bracket tags like [ar:Artist] or (by: Creator)
      if ((trimmed.startsWith('[') && trimmed.endsWith(']')) ||
          (trimmed.startsWith('(') && trimmed.endsWith(')'))) {
        final inner =
            trimmed.substring(1, trimmed.length - 1).trim().toLowerCase();
        for (final kw in [
          'ti',
          'ar',
          'al',
          'by',
          'offset',
          're',
          've',
          'title',
          'artist',
          'song',
          'album',
          'lyrics',
          'composer',
          'producer',
        ]) {
          if (inner.startsWith('$kw:') || inner.startsWith('$kw：')) {
            return true;
          }
        }
      }

      final lower = trimmed.toLowerCase();

      // Only check credit lines within the first 15 seconds of the track
      if (lineDuration.inSeconds <= 15) {
        // Multi-word credit phrases
        const creditPhrases = [
          'written by',
          'composed by',
          'produced by',
          'lyrics by',
          'arranged by',
          'mixed by',
          'mastered by',
          'synced by',
          'lrc by',
          'vocals by',
          'music by',
          'performed by',
          'recorded by',
          'engineered by',
          'translated by',
        ];
        for (final phrase in creditPhrases) {
          if (lower.startsWith('$phrase:') ||
              lower.startsWith('$phrase：') ||
              lower.startsWith('$phrase ')) {
            return true;
          }
        }

        // Single-word credit tags MUST be followed by a colon ':' or '：'
        // This ensures real lyrics starting with words like "Music", "Singer", "Song" are never discarded.
        const colonKeywords = [
          'ti:',
          'ar:',
          'al:',
          'by:',
          'offset:',
          're:',
          've:',
          'ti：',
          'ar：',
          'al：',
          'by：',
          'offset：',
          're：',
          've：',
          'title:',
          'artist:',
          'song:',
          'track:',
          'album:',
          'title：',
          'artist：',
          'song：',
          'track：',
          'album：',
          'composer:',
          'lyricist:',
          'arranger:',
          'producer:',
          'composer：',
          'lyricist：',
          'arranger：',
          'producer：',
          'vocals:',
          'singer:',
          'lyrics:',
          'mix:',
          'master:',
          'vocals：',
          'singer：',
          'lyrics：',
          'mix：',
          'master：',
          '作词:',
          '作曲:',
          '编曲:',
          '演唱:',
          '制作:',
          '混音:',
          '母带:',
          '作词：',
          '作曲：',
          '编曲：',
          '演唱：',
          '制作：',
          '混音：',
          '母带：',
        ];
        for (final tag in colonKeywords) {
          if (lower.startsWith(tag) || lower.contains(tag)) {
            return true;
          }
        }
      }

      return false;
    }

    for (final rawLine in lrcContent.split('\n')) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      final matches = timestampRegex.allMatches(trimmed).toList();
      if (matches.isEmpty) continue;

      // Extract text with all timestamp tags stripped
      final text = trimmed.replaceAll(timestampRegex, '').trim();

      // Skip non-lyric bracket tags like [ar:Artist]
      if (text.startsWith('[') && text.endsWith(']')) {
        continue;
      }

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final fractionStr = match.group(3) ?? '0';

        int milliseconds = 0;
        if (fractionStr.length == 1) {
          milliseconds = (int.tryParse(fractionStr) ?? 0) * 100;
        } else if (fractionStr.length == 2) {
          milliseconds = (int.tryParse(fractionStr) ?? 0) * 10;
        } else if (fractionStr.length == 3) {
          milliseconds = int.tryParse(fractionStr) ?? 0;
        }

        // Standard LRC specification:
        // [offset:+/-ms] Overall timestamp adjustment in milliseconds.
        // Positive offset (+) means lyrics should appear sooner (advance lyrics).
        // Negative offset (-) means lyrics should appear later (delay lyrics).
        // Therefore, offsetMs is subtracted from the timestamp.
        var totalMs =
            minutes * 60000 + seconds * 1000 + milliseconds - offsetMs;
        if (totalMs < 0) totalMs = 0;

        final duration = Duration(milliseconds: totalMs);

        // Filter metadata / credits lines
        if (isCreditOrMetadata(text, duration)) {
          continue;
        }

        rawLines.add(LyricLine(timestamp: duration, text: text));
      }
    }

    if (rawLines.isEmpty) return const [];

    // Sort strictly by timestamp
    rawLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate endTimes: empty lines or subsequent line timestamps
    final List<LyricLine> result = [];
    for (final line in rawLines) {
      if (line.text.isEmpty) {
        // Empty line (pause / interlude marker) marks end of previous line
        if (result.isNotEmpty && result.last.endTime == null) {
          final end = line.timestamp > result.last.timestamp
              ? line.timestamp
              : result.last.timestamp + const Duration(milliseconds: 1500);
          result[result.length - 1] = result.last.copyWith(endTime: end);
        }
      } else {
        // Preceding line without an explicit end time defaults to this line's start
        if (result.isNotEmpty && result.last.endTime == null) {
          final end = line.timestamp > result.last.timestamp
              ? line.timestamp
              : result.last.timestamp + const Duration(milliseconds: 1500);
          result[result.length - 1] = result.last.copyWith(endTime: end);
        }
        result.add(line);
      }
    }

    return result;
  }

  // Fast binary search to find the active line index for a given playback position.
  // In synced lyrics display  a line remains
  // active from its start timestamp until the next line starts. Instrumental interludes
  // are represented by explicit '♪' lines in timed lyrics.
  static int findActiveLineIndex(
    List<LyricLine> lines,
    Duration position, {
    Duration offset = Duration.zero,
  }) {
    if (lines.isEmpty) return -1;
    final effectivePosition = position + offset;
    // Before the very first line starts (e.g. song intro)
    if (effectivePosition < lines.first.timestamp) return -1;

    int low = 0;
    int high = lines.length - 1;
    int candidate = -1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (lines[mid].timestamp <= effectivePosition) {
        candidate = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return candidate;
  }

  @override
  List<Object?> get props => [plainLyrics, syncedLyrics];
}
