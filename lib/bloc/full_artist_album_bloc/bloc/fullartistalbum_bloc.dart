import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'fullartistalbum_event.dart';
part 'fullartistalbum_state.dart';

class FullArtistAlbumBloc
    extends Bloc<FullArtistAlbumEvent, FullArtistAlbumState> {
  final Repository _repository;
  FullArtistAlbumBloc(this._repository) : super(FullartistalbumInitial()) {
    on<SetFullartistalbumInitialEvent>(_setFullartistalbumInitialState);
    on<GetArtistAlbumsEvent>(_getArtitsAlbums);
  }

  void _setFullartistalbumInitialState(SetFullartistalbumInitialEvent event,
      Emitter<FullArtistAlbumState> emit) {
    emit(FullartistalbumInitial());
  }

  Future<void> _getArtitsAlbums(
      GetArtistAlbumsEvent event, Emitter<FullArtistAlbumState> emit) async {
    emit(LoadingState());
    try {
      final data = await _repository.getArtistAlbums(event.artist);
      emit(FullartistalbumDataState(artistAlbums: data));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
