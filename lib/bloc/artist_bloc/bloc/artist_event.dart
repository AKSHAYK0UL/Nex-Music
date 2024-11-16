part of 'artist_bloc.dart';

sealed class ArtistEvent {}

final class SetStateToinitialEvent extends ArtistEvent {}

final class GetArtistEvent extends ArtistEvent {
  final String inputText;

  GetArtistEvent({required this.inputText});
}
