part of 'full_artist_playlist_bloc.dart';

sealed class FullArtistPlaylistState extends Equatable {
  const FullArtistPlaylistState();

  @override
  List<Object> get props => [];
}

final class FullArtistPlaylistInitial extends FullArtistPlaylistState {
  @override
  List<Object> get props => [];
}

final class LoadingState extends FullArtistPlaylistState {
  @override
  List<Object> get props => [];
}

final class ErrorState extends FullArtistPlaylistState {
  final String errorMessage;

  const ErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

// ignore: must_be_immutable
final class FullArtistPlaylistDataState extends FullArtistPlaylistState {
  List<PlayListmodel> playlistData;
  FullArtistPlaylistDataState({required this.playlistData});
  @override
  List<Object> get props => [playlistData];
}
