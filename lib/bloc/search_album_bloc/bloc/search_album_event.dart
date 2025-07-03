part of 'search_album_bloc.dart';

sealed class SearchAlbumEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class SetStateToInitialSearchAlbumBlocEvent extends SearchAlbumEvent {
  @override
  List<Object> get props => [];
}

final class SearchAlbumsEvent extends SearchAlbumEvent {
  final String inputText;

  SearchAlbumsEvent({required this.inputText});
  @override
  List<Object> get props => [inputText];
}
