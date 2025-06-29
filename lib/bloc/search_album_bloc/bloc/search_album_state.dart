part of 'search_album_bloc.dart';

sealed class SearchAlbumState extends Equatable {
  @override
  List<Object> get props => [];
}

final class SearchAlbumInitial extends SearchAlbumState {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
final class SearchedAlbumsDataState extends SearchAlbumState {
  List<PlayListmodel> albums = [];
  SearchedAlbumsDataState({required this.albums});

  @override
  List<Object> get props => [albums];
}

final class LoadingState extends SearchAlbumState {
  @override
  List<Object> get props => [];
}

final class ErrorState extends SearchAlbumState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
