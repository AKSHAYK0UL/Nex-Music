part of 'saved_playlists_bloc.dart';

sealed class SavedPlaylistsState {}

final class SavedPlaylistsInitial extends SavedPlaylistsState {}

final class LoadingStateSavedPlaylists extends SavedPlaylistsState {}

final class ErrorStateSavedPlaylists extends SavedPlaylistsState {
  final String errorMessage;

  ErrorStateSavedPlaylists({required this.errorMessage});
}

final class IsPlaylistSavedState extends SavedPlaylistsState {
  final bool isSaved;
  final String playlistId;
  final Stream<List<SavedPlaylistModel>>? playlists;

  IsPlaylistSavedState({
    required this.isSaved, 
    required this.playlistId,
    this.playlists,
  });
}

final class SavedPlaylistsDataState extends SavedPlaylistsState {
  final Stream<List<SavedPlaylistModel>> playlists;
  final bool? lastIsSaved;
  final String? lastPlaylistId;

  SavedPlaylistsDataState({
    required this.playlists,
    this.lastIsSaved,
    this.lastPlaylistId,
  });
}
