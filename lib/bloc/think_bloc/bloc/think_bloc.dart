import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/secrets/think_input.dart';
import 'package:nex_music/secrets/think_key.dart';

part 'think_event.dart';
part 'think_state.dart';

class ThinkBloc extends Bloc<ThinkEvent, ThinkState> {
  final DbRepository _dbRepository;

  ThinkBloc(this._dbRepository) : super(ThinkInitial()) {
    on<LoadRecentSongsInThink>(_generateDiscoverSongList);
  }

  Future<void> _generateDiscoverSongList(
      LoadRecentSongsInThink event, Emitter<ThinkState> emit) async {
    try {
      final recentPlayedStream = await _dbRepository.getRecentPlayed().first;
      final jsonData =
          recentPlayedStream.take(20).map((e) => e.toJson()).toList();

      final model = GenerativeModel(model: THINK_MODEL, apiKey: THINK_API_KEY);
      final content = [Content.text(thinkInput(jsonData))];
      final geminiresponse = await model.generateContent(content);
      print(geminiresponse.text!);
    } catch (e) {}
  }
}
