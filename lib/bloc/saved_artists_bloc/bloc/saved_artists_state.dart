part of 'saved_artists_bloc.dart';

sealed class SavedArtistsState {}

final class SavedArtistsInitial extends SavedArtistsState {}

final class LoadingStateSavedArtists extends SavedArtistsState {}

final class ErrorStateSavedArtists extends SavedArtistsState {
  final String errorMessage;

  ErrorStateSavedArtists({required this.errorMessage});
}

final class IsArtistSavedState extends SavedArtistsState {
  final bool isSaved;
  final String artistId;

  IsArtistSavedState({required this.isSaved, required this.artistId});
}

final class SavedArtistsDataState extends SavedArtistsState {
  final Stream<List<ArtistModel>> artists;

  SavedArtistsDataState({required this.artists});
}

