part of 'full_artist_video_bloc_bloc.dart';

sealed class FullArtistVideoBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class SetFullArtistVideoBlocInitialEvent
    extends FullArtistVideoBlocEvent {
  @override
  List<Object> get props => [];
}

final class GetArtistVideosEvent extends FullArtistVideoBlocEvent {
  final String inputText;

  GetArtistVideosEvent({required this.inputText});
  @override
  List<Object> get props => [inputText];
}
