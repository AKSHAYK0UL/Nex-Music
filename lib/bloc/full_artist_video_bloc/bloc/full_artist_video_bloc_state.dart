part of 'full_artist_video_bloc_bloc.dart';

sealed class FullArtistVideoBlocState extends Equatable {
  @override
  List<Object> get props => [];
}

final class FullArtistVideoBlocInitial extends FullArtistVideoBlocState {
  @override
  List<Object> get props => [];
}

final class LoadingState extends FullArtistVideoBlocState {
  @override
  List<Object> get props => [];
}

final class ErrorState extends FullArtistVideoBlocState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

// ignore: must_be_immutable
final class ArtistVideosDataState extends FullArtistVideoBlocState {
  List<Songmodel> artistVidoes;
  ArtistVideosDataState({required this.artistVidoes});
  @override
  List<Object> get props => [artistVidoes];
}
