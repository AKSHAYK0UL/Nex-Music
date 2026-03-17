part of 'saved_artists_bloc.dart';

sealed class SavedArtistsEvent {}

final class AddToSavedArtistsEvent extends SavedArtistsEvent {
  final ArtistModel artist;

  AddToSavedArtistsEvent({required this.artist});
}

final class IsArtistSavedEvent extends SavedArtistsEvent {
  final String artistId;

  IsArtistSavedEvent({required this.artistId});
}

final class RemoveFromSavedArtistsEvent extends SavedArtistsEvent {
  final String artistId;
  RemoveFromSavedArtistsEvent({required this.artistId});
}

final class GetSavedArtistsEvent extends SavedArtistsEvent {}

