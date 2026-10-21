import 'package:equatable/equatable.dart';

class LyricLine extends Equatable {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });

  @override
  List<Object?> get props => [timestamp, text];
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
    final List<LyricLine> lines = [];
    final RegExp regExp = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\](.*)');

    for (final rawLine in lrcContent.split('\n')) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      final matches = regExp.allMatches(trimmed);
      if (matches.isEmpty) continue;

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final fractionStr = match.group(3) ?? '0';

        int milliseconds = 0;
        if (fractionStr.length == 2) {
          milliseconds = (int.tryParse(fractionStr) ?? 0) * 10;
        } else if (fractionStr.length == 3) {
          milliseconds = int.tryParse(fractionStr) ?? 0;
        }

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        final text = match.group(4)?.trim() ?? '';
        lines.add(LyricLine(timestamp: duration, text: text));
      }
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }

  @override
  List<Object?> get props => [plainLyrics, syncedLyrics];
}
