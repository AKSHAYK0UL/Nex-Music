part of 'full_artist_playlist_bloc.dart';

sealed class FullArtistPlaylistEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class SetFullArtistPlaylistInitialEvent extends FullArtistPlaylistEvent {
  @override
  List<Object> get props => [];
}

final class GetFullArtistPlaylistEvent extends FullArtistPlaylistEvent {
  final String inputText;

  GetFullArtistPlaylistEvent({required this.inputText});
  @override
  List<Object> get props => [inputText];
}
