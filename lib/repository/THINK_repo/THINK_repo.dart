import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/secrets/think_input.dart';
import 'package:nex_music/secrets/think_key.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ThinkRepo {
  final DbRepository _dbRepository;

  ThinkRepo({required DbRepository dbRepository})
      : _dbRepository = dbRepository;

  Future<String> get getTHINKInputPrompt async {
    try {
      final recentPlayedStream = await _dbRepository.getRecentPlayed().first;
      final jsonData = recentPlayedStream.map((e) => e.toJson()).toList();

      final model = GenerativeModel(model: THINK_MODEL, apiKey: THINK_API_KEY);
      final content = [Content.text(thinkInput(jsonData))];
      final geminiresponse = await model.generateContent(content);
      return geminiresponse.text!;
    } catch (_) {
      rethrow;
    }
  }
}
