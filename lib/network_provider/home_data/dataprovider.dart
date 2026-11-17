import 'package:dart_ytmusic_api/types.dart' as yt;
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:nex_music/network_provider/home_data/lyrics_network_provider.dart';
import 'package:nex_music/secrets/gcp_key.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DataProvider {
  final YTMusic _ytMusic;
  final YoutubeExplode _youtubeExplode;
  final LyricsNetworkProvider _lyricsNetworkProvider;

  DataProvider({
    required YTMusic ytMusic,
    required YoutubeExplode youtubeExplode,
  })  : _ytMusic = ytMusic,
        _youtubeExplode = youtubeExplode,
        _lyricsNetworkProvider = LyricsNetworkProvider(ytMusic: ytMusic);

  Future<LyricModel?> getLyrics({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) {
    return _lyricsNetworkProvider.fetchLyrics(
      title: title,
      artist: artist,
      videoId: videoId,
      durationSeconds: durationSeconds,
    );
  }

  Future<LyricModel?> getLyricsYtOnly({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) {
    return _lyricsNetworkProvider.fetchYtMusicOnly(
      title: title,
      artist: artist,
      videoId: videoId,
      durationSeconds: durationSeconds,
    );
  }

  Future<LyricModel?> getLyricsLrclibOnly({
    required String title,
    required String artist,
    int? durationSeconds,
  }) {
    return _lyricsNetworkProvider.fetchLrclibOnly(
      title: title,
      artist: artist,
      durationSeconds: durationSeconds,
    );
  }

//cancel all ongoing request
  void cancelRequest() {
    // _ytMusic.dio.close();//remove in new version 1.3.6
    _youtubeExplode.close();
  }

  Future<void> _ensureInitialized() async {
    if (!_ytMusic.hasInitialized) {
      final savedCookies = HiveDataBaseSingleton.instance.ytMusicCookie;
      await _ytMusic.initialize(
        cookies: savedCookies,
        dataApiKey: ytApIKey,
      );
    }
  }

  Future<void> updateYtMusicCookies(String? cookies) async {
    if (cookies != null && cookies.isNotEmpty) {
      _ytMusic.setCookies(cookies);
    } else {
      _ytMusic.clearCookies();
    }
  }

  Future<void> reportPlayback({
    required String videoId,
    required int songDuration,
    int? listenedSeconds,
  }) async {
    await _ensureInitialized();
    await _ytMusic.reportPlayback(
      videoId: videoId,
      songDuration: songDuration,
      listenedSeconds: listenedSeconds,
    );
  }

  //get home section data
  Future<
      ({
        List<yt.HomeSection> homeSectionData,
        List<yt.SongDetailed> quickPicks
      })> homeScreenSongs(String inputPrompt) async {
    await _ensureInitialized();
    final isRecommendationOn =
        HiveDataBaseSingleton.instance.recommendationStatus;
    final savedCookies = HiveDataBaseSingleton.instance.ytMusicCookie;
    if (isRecommendationOn && savedCookies != null && savedCookies.isNotEmpty) {
      _ytMusic.setCookies(savedCookies);
    } else {
      _ytMusic.clearCookies();
    }

    debugPrint(
        'homeScreenSongs: recommendationOn=$isRecommendationOn, hasCookies=${savedCookies != null && savedCookies.isNotEmpty}, ytMusicAuthenticated=${_ytMusic.isAuthenticated}, sapisid=${_ytMusic.sapisid != null}');

    final fetchedData = await Future.wait(
      [
        _ytMusic.getHome(country: isRecommendationOn ? null : 'IN'),
        _ytMusic.searchSongs(inputPrompt),
      ],
    );

    final homeSectionData =
        fetchedData[0] as List<yt.HomeSection>; //PlayList, Album
    final quickPicks = fetchedData[1] as List<yt.SongDetailed>; ////Quick Picks

    debugPrint(
        'homeScreenSongs: loaded ${homeSectionData.length} home sections: ${homeSectionData.map((s) => s.title).toList()}');

    return (homeSectionData: homeSectionData, quickPicks: quickPicks);
  }

  // Get playlist videos via YTMusic
  Future<List<yt.VideoDetailed>> getPlaylistVideos(String playlistId) async {
    await _ensureInitialized();
    return await _ytMusic.getPlaylistVideos(playlistId);
  }

  // Get full album via YTMusic
  Future<yt.AlbumFull> getAlbum(String albumId) async {
    await _ensureInitialized();
    return await _ytMusic.getAlbum(albumId);
  }

  // Get full playlist details via YTMusic
  Future<yt.PlaylistFull> getPlaylist(String playlistId) async {
    await _ensureInitialized();
    return await _ytMusic.getPlaylist(playlistId);
  }

  Future<StreamManifest> songStreamUrl(String songId) {
    return _youtubeExplode.videos.streamsClient.getManifest(
      songId,
      requireWatchPage: false,
      validateStreams: false,
    );
  }

  Future<yt.SongFull> getSongForDeeplinkSearchSong(String songId) async {
    return await _ytMusic.getSong(songId);
  }

  Future<yt.VideoFull> getSongForDeeplinkSearchVideo(String songId) async {
    return await _ytMusic.getVideo(songId);
  }

  //search suggestion
  Future<List<String>> searchSuggestion(String query) async {
    return await _ytMusic.getSearchSuggestions(query);
  }

  //search in songs
  Future<List<yt.SongDetailed>> searchSong(String inputText) async {
    return await _ytMusic.searchSongs(inputText);
  }

  //search in videos
  Future<List<yt.VideoDetailed>> searchVideo(String inputText) async {
    return await _ytMusic.searchVideos(inputText);
  }

  //search In playlist
  Future<List<yt.PlaylistDetailed>> searchPlaylist(String inputText) async {
    return await _ytMusic.searchPlaylists(inputText);
  }

  //search artist
  Future<List<yt.ArtistDetailed>> searchArtist(String inputText) async {
    return await _ytMusic.searchArtists(inputText);
  }

  //search Albums
  Future<List<AlbumDetailed>> searchAlbums(String inputText) async {
    return await _ytMusic.searchAlbums(inputText);
  }

  //get Artist songs
  Future<List<yt.SongDetailed>> getArtistSongs(String artistId) async {
    return await _ytMusic.getArtistSongs(artistId);
  }

  //get artist album
  Future<List<AlbumDetailed>> getArtistAlbums(String artistId) async {
    return await _ytMusic.getArtistAlbums(artistId);
  }

  //get artist full details
  Future<yt.ArtistFull> getArtist(String artistId) async {
    return await _ytMusic.getArtist(artistId);
  }

  //get artist singles
  Future<List<AlbumDetailed>> getArtistSingles(String artistId) async {
    return await _ytMusic.getArtistSingles(artistId);
  }

  //get up next songs for radio feature
  Future<List<UpNextsDetails>> getUpNexts(String videoId) async {
    return await _ytMusic.getUpNexts(videoId);
  }
}
