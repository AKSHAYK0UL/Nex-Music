part of 'user_playlist_bloc.dart';

sealed class UserPlaylistState {}

final class UserPlaylistInitial extends UserPlaylistState {}

final class UserPlaylistLoadingState extends UserPlaylistState {}

final class UserPlaylistDataState extends UserPlaylistState {
  final Stream<List<String>> data;

  UserPlaylistDataState({required this.data});
}

final class UserPlaylistErrorState extends UserPlaylistState {
  final String errorMessage;

  UserPlaylistErrorState({required this.errorMessage});
}

final class UserPlaylistSongsDataState extends UserPlaylistState {
  final Stream<List<Songmodel>> data;

  UserPlaylistSongsDataState({required this.data});
}
