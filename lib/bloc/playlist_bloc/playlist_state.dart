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
  final String playlistDuration;

  PlaylistDataState({
    required this.playlistSongs,
    required this.totalSongs,
    this.isLoading = false,
    required this.playlistDuration,
  });

  PlaylistDataState copyWith({
    List<Songmodel>? playlistSongs,
    int? totalSongs,
    bool? isLoading,
    String? playlistDuration,
  }) {
    return PlaylistDataState(
      playlistSongs: playlistSongs ?? this.playlistSongs,
      totalSongs: totalSongs ?? this.totalSongs,
      isLoading: isLoading ?? this.isLoading,
      playlistDuration: playlistDuration ?? this.playlistDuration,
    );
  }
}
