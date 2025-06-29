import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'full_artist_video_bloc_event.dart';
part 'full_artist_video_bloc_state.dart';

class FullArtistVideoBloc
    extends Bloc<FullArtistVideoBlocEvent, FullArtistVideoBlocState> {
  final Repository _repository;
  FullArtistVideoBloc(this._repository) : super(FullArtistVideoBlocInitial()) {
    on<SetFullArtistVideoBlocInitialEvent>(_setFullArtistVideoInitialStata);
    on<GetArtistVideosEvent>(_artistVideos);
  }

  void _setFullArtistVideoInitialStata(SetFullArtistVideoBlocInitialEvent event,
      Emitter<FullArtistVideoBlocState> emit) {
    emit(FullArtistVideoBlocInitial());
  }

  Future<void> _artistVideos(GetArtistVideosEvent event,
      Emitter<FullArtistVideoBlocState> emit) async {
    emit(LoadingState());
    try {
      final data = await _repository.searchVideo(event.inputText);
      emit(ArtistVideosDataState(artistVidoes: data));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
