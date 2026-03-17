part of 'homesection_bloc.dart';

sealed class HomesectionState {}

final class HomesectionInitial extends HomesectionState {}

final class LoadingState extends HomesectionState {}

final class ErrorState extends HomesectionState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class HomeSectionStateData extends HomesectionState {
  final List<Songmodel> quickPicks;
  final List<PlayListmodel> playlist;
  final List<PlayListmodel> albums;
  
  // Global sections
  final List<PlayListmodel> globalHitsPlaylists;
  final List<PlayListmodel> trendingGloballyPlaylists;
  
  // Trending Punjabi
  final List<PlayListmodel> trendingPunjabiPlaylists;
  final List<PlayListmodel> trendingPunjabiAlbums;
  
  // Trending Hindi
  final List<PlayListmodel> trendingHindiPlaylists;
  final List<PlayListmodel> trendingHindiAlbums;
  
  // Trending English
  final List<PlayListmodel> trendingEnglishPlaylists;
  
  // Trending Phonk
  final List<PlayListmodel> trendingPhonkPlaylists;
  final List<PlayListmodel> trendingPhonkAlbums;
  
  // Trending Brazilian Phonk
  final List<PlayListmodel> trendingBrazilianPhonkPlaylists;
  final List<PlayListmodel> trendingBrazilianPhonkAlbums;
  
  // Nonstop Mashup
  final List<PlayListmodel> nonstopPunjabiMashup;
  final List<PlayListmodel> nonstopHindiMashup;
  final List<PlayListmodel> nonstopEnglishMashup;

  HomeSectionStateData({
    required this.quickPicks,
    required this.playlist,
    required this.albums,
    required this.globalHitsPlaylists,
    required this.trendingGloballyPlaylists,
    required this.trendingPunjabiPlaylists,
    required this.trendingPunjabiAlbums,
    required this.trendingHindiPlaylists,
    required this.trendingHindiAlbums,
    required this.trendingEnglishPlaylists,
    required this.trendingPhonkPlaylists,
    required this.trendingPhonkAlbums,
    required this.trendingBrazilianPhonkPlaylists,
    required this.trendingBrazilianPhonkAlbums,
    required this.nonstopPunjabiMashup,
    required this.nonstopHindiMashup,
    required this.nonstopEnglishMashup,
  });
}
