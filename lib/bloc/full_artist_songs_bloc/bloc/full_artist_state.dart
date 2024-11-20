part of 'full_artist_bloc.dart';

sealed class FullArtistSongState extends Equatable {}

final class FullArtistInitial extends FullArtistSongState {
  @override
  List<Object?> get props => [];
}

final class LoadingStata extends FullArtistSongState {
  @override
  List<Object?> get props => [];
}

final class ErrorState extends FullArtistSongState {
  final String errorMessage;

  ErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ignore: must_be_immutable
final class ArtistSongsState extends FullArtistSongState {
  List<Songmodel> artistSongs = [];
  ArtistSongsState({required this.artistSongs});
  @override
  List<Object?> get props => [artistSongs];
}
