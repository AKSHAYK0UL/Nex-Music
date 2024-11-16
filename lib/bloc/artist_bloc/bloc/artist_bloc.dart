import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final Repository _repository;
  ArtistBloc(this._repository) : super(ArtistInitial()) {
    on<SetStateToinitialEvent>(_setStateToInitial);
    on<GetArtistEvent>(_getArtist);
  }
  void _setStateToInitial(
      SetStateToinitialEvent event, Emitter<ArtistState> emit) {
    emit(ArtistInitial());
  }

  Future<void> _getArtist(
      GetArtistEvent event, Emitter<ArtistState> emit) async {
    emit(LoadingState());
    try {
      final artists = await _repository.searchArtist(event.inputText);
      emit(ArtistDataState(artists: artists));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
