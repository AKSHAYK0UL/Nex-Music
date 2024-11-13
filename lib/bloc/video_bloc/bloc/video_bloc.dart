import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final Repository _repository;
  VideoBloc(this._repository) : super(VideoInitial()) {
    on<SearchInVideoEvent>(_searchInVideo);
  }
  //search In video
  Future<void> _searchInVideo(
      SearchInVideoEvent event, Emitter<VideoState> emit) async {
    emit(LoadingState());
    try {
      final videoResult = await _repository.searchVideo(event.inputText);
      emit(VideosResultState(searchedVideo: videoResult));
    } catch (e) {
      emit(ErrorState(errorMessage: e.toString()));
    }
  }
}
