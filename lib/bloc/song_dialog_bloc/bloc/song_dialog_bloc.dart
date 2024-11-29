import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';

part 'song_dialog_event.dart';
part 'song_dialog_state.dart';

class SongDialogBloc extends Bloc<SongDialogEvent, SongDialogState> {
  final DbRepository _dbRepository;
  SongDialogBloc(this._dbRepository) : super(SongDialogInitial()) {
    on<RemoveFromRecentlyPlayedEvent>(_removeFromRecentPlayed);
  }
  Future<void> _removeFromRecentPlayed(RemoveFromRecentlyPlayedEvent event,
      Emitter<SongDialogState> emit) async {
    emit(LoadingState());
    try {
      await _dbRepository.deleteRecentPlayedSong(event.vId);
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
