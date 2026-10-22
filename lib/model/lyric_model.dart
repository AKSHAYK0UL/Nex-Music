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

    // Metadata keywords to filter out credits at the beginning of LRC (<= 2.5s)
    final metadataKeywords = [
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
      'track',
      'album',
      'composer',
      'music',
      'lyrics',
      'lyricist',
      'singer',
      'arranger',
      'arranged by',
      'producer',
      'produced by',
      'written by',
      'composed by',
      'lyrics by',
      'vocals',
      'feat',
      'featuring',
      'mix',
      'mixed by',
      'master',
      'mastered by',
      'record',
      'label',
      'lrc by',
      'synced by',
      'encoded by',
      '作词',
      '作曲',
      '编曲',
      '演唱',
      '制作',
      '混音',
      '母带',
    ];

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

        var totalMs =
            minutes * 60000 + seconds * 1000 + milliseconds + offsetMs;
        if (totalMs < 0) totalMs = 0;

        final duration = Duration(milliseconds: totalMs);

        // Filter metadata credits at <= 2.5 seconds
        if (duration.inMilliseconds <= 2500 && text.isNotEmpty) {
          final lower = text.toLowerCase();
          final isMeta = metadataKeywords.any(
            (kw) =>
                lower.startsWith('$kw:') ||
                lower.startsWith('$kw：') ||
                lower.startsWith('$kw ') ||
                lower == kw ||
                lower.contains('$kw:') ||
                lower.contains('$kw：'),
          );
          if (isMeta) continue;
        }

        rawLines.add(LyricLine(timestamp: duration, text: text));
      }
    }

    if (rawLines.isEmpty) return const [];

    // Sort strictly by timestamp
    rawLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    //  empty lines define the endTime of previous sung line
    final List<LyricLine> result = [];
    for (final line in rawLines) {
      if (line.text.isEmpty) {
        // Empty line (pause / interlude marker) marks end of previous line
        if (result.isNotEmpty && result.last.endTime == null) {
          result[result.length - 1] =
              result.last.copyWith(endTime: line.timestamp);
        }
      } else {
        // If preceding line didn't have an explicit end time, default to this line's start
        if (result.isNotEmpty && result.last.endTime == null) {
          result[result.length - 1] =
              result.last.copyWith(endTime: line.timestamp);
        }
        result.add(line);
      }
    }

    return result;
  }

  @override
  List<Object?> get props => [plainLyrics, syncedLyrics];
}
