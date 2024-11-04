part of 'playlist_bloc.dart';

sealed class PlaylistState {}

final class PlaylistInitial extends PlaylistState {}

final class LoadingState extends PlaylistState {}

final class ErrorState extends PlaylistState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class PlaylistDataState extends PlaylistState {
  final List<Songmodel> playlistSongs;
  final int totalSongs;
  final bool isLoading;

  PlaylistDataState({
    required this.playlistSongs,
    required this.totalSongs,
    this.isLoading = false,
  });

  PlaylistDataState copyWith({
    List<Songmodel>? playlistSongs,
    int? totalSongs,
    bool? isLoading,
  }) {
    return PlaylistDataState(
      playlistSongs: playlistSongs ?? this.playlistSongs,
      totalSongs: totalSongs ?? this.totalSongs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
