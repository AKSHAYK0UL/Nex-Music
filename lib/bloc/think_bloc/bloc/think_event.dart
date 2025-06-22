part of 'think_bloc.dart';

sealed class ThinkEvent extends Equatable {
  const ThinkEvent();

  @override
  List<Object> get props => [];
}

final class LoadRecentSongsInThink extends ThinkEvent {
  // List<Songmodel> recentSongs;
  // LoadRecentSongsInThink({required this.recentSongs});
}
