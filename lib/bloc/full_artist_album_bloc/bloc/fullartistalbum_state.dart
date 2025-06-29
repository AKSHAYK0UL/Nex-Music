part of 'fullartistalbum_bloc.dart';

sealed class FullArtistAlbumState extends Equatable {}

final class FullartistalbumInitial extends FullArtistAlbumState {
  @override
  List<Object?> get props => [];
}

final class LoadingState extends FullArtistAlbumState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends FullArtistAlbumState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

// ignore: must_be_immutable
final class FullartistalbumDataState extends FullArtistAlbumState {
  List<PlayListmodel> artistAlbums;
  FullartistalbumDataState({required this.artistAlbums});
  @override
  List<Object?> get props => [artistAlbums];
}
