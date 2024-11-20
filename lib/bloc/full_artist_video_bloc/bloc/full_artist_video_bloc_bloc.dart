import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'full_artist_video_bloc_event.dart';
part 'full_artist_video_bloc_state.dart';

class FullArtistVideoBloc
    extends Bloc<FullArtistVideoBlocEvent, FullArtistVideoBlocState> {
  FullArtistVideoBloc() : super(FullArtistVideoBlocInitial()) {
    on<FullArtistVideoBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
