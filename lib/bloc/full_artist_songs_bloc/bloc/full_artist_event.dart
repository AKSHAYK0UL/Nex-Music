part of 'full_artist_bloc.dart';

sealed class FullArtistSongEvent extends Equatable {}

final class GetArtistSongsEvent extends FullArtistSongEvent {
  final String artistId;

  GetArtistSongsEvent({required this.artistId});
  @override
  List<Object?> get props => [artistId];
}
