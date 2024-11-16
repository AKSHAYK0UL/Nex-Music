part of 'artist_bloc.dart';

sealed class ArtistState {}

final class ArtistInitial extends ArtistState {}

final class LoadingState extends ArtistState {}

final class ErrorState extends ArtistState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class ArtistDataState extends ArtistState {
  List<ArtistModel> artists = [];
  ArtistDataState({required this.artists});
}
