part of 'upnext_bloc.dart';

sealed class UpnextState {}

final class UpnextInitial extends UpnextState {}

final class UpnextLoadingState extends UpnextState {}

final class UpnextErrorState extends UpnextState {
  final String errorMessage;

  UpnextErrorState({required this.errorMessage});
}

final class UpnextLoadedState extends UpnextState {
  final List<Songmodel> upcomingSongs;
  final List<Songmodel> allPlaylistSongs;
  final int currentSongIndex;
  final bool shouldShowStartRadio;
  final bool isRadioLoading;

  UpnextLoadedState({
    required this.upcomingSongs,
    required this.shouldShowStartRadio,
    this.allPlaylistSongs = const [],
    this.currentSongIndex = -1,
    this.isRadioLoading = false,
  });

  UpnextLoadedState copyWith({
    List<Songmodel>? upcomingSongs,
    List<Songmodel>? allPlaylistSongs,
    int? currentSongIndex,
    bool? shouldShowStartRadio,
    bool? isRadioLoading,
  }) {
    return UpnextLoadedState(
      upcomingSongs: upcomingSongs ?? this.upcomingSongs,
      allPlaylistSongs: allPlaylistSongs ?? this.allPlaylistSongs,
      currentSongIndex: currentSongIndex ?? this.currentSongIndex,
      shouldShowStartRadio: shouldShowStartRadio ?? this.shouldShowStartRadio,
      isRadioLoading: isRadioLoading ?? this.isRadioLoading,
    );
  }
}
