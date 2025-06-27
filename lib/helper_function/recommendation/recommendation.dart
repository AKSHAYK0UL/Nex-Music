import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/secrets/think.dart';

Future<String> recommendationPrompt(DbRepository db) async {
  try {
    final recentData = await db.getRecentPlayed().first;
    if (recentData.isEmpty) {
      return DEFAULT_PROMPT;
    }
    final uniqueArtists =
        recentData.take(14).map((e) => e.forRecommendation()).toSet();
    final resultPrompt = uniqueArtists.join(", ");

    return resultPrompt;
  } on FirebaseException catch (_) {
    rethrow;
  } catch (_) {
    rethrow;
  }
}
