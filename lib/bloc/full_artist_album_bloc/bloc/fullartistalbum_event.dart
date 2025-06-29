part of 'fullartistalbum_bloc.dart';

sealed class FullArtistAlbumEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SetFullartistalbumInitialEvent extends FullArtistAlbumEvent {
  @override
  List<Object?> get props => [];
}

final class GetArtistAlbumsEvent extends FullArtistAlbumEvent {
  final ArtistModel artist;

  GetArtistAlbumsEvent({required this.artist});
  @override
  List<Object?> get props => [artist];
}
