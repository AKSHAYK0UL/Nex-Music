import 'package:dart_ytmusic_api/types.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/helper_function/repository/repository_helper_function.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Repository {
  final YoutubeExplode _yt;
  final DataProvider _dataProvider;
  final HiveDataBaseSingleton _dbInstance;

  Repository(
      {required DataProvider dataProvider,
      required YoutubeExplode yt,
      required HiveDataBaseSingleton dbInstance})
      : _dataProvider = dataProvider,
        _yt = yt,
        _dbInstance = dbInstance;

//cancel all ongoing request
  void cancelRequest() {
    _dataProvider.cancelRequest();
  }

//using records
  Future<
      ({
        List<Songmodel> quickPicks,
        List<PlayListmodel> playlist,
        List<PlayListmodel> albums,
        List<PlayListmodel> globalHitsPlaylists,
        List<PlayListmodel> trendingGloballyPlaylists,
        List<PlayListmodel> trendingPunjabiPlaylists,
        List<PlayListmodel> trendingPunjabiAlbums,
        List<PlayListmodel> trendingHindiPlaylists,
        List<PlayListmodel> trendingHindiAlbums,
        List<PlayListmodel> trendingEnglishPlaylists,
        List<PlayListmodel> trendingPhonkPlaylists,
        List<PlayListmodel> trendingPhonkAlbums,
        List<PlayListmodel> trendingBrazilianPhonkPlaylists,
        List<PlayListmodel> trendingBrazilianPhonkAlbums,
        List<PlayListmodel> nonstopPunjabiMashup,
        List<PlayListmodel> nonstopHindiMashup,
        List<PlayListmodel> nonstopEnglishMashup,
      })> homeScreenSongsList(String inputPrompt) async {
    final quality = _dbInstance.getData;

    // Fetch main home data first (required)
    final networkData = await _dataProvider.homeScreenSongs(inputPrompt);

    final quickPicks = await RepositoryHelperFunction.getQuickPicks(
        networkData.quickPicks, quality.thumbnailQuality);

    final playlist =
        RepositoryHelperFunction.getPlaylists(networkData.homeSectionData);

    final albums =
        RepositoryHelperFunction.getAlbums(networkData.homeSectionData);

    // Fetch trending data in parallel (optional - failures return empty lists)
    final trendingResults = await Future.wait([
      // Global sections
      _safeSearchPlaylist("global hits playlist"),
      _safeSearchPlaylist("trending globally playlist"),
      
      // Trending Punjabi
      _safeSearchPlaylist("trending punjabi playlist"),
      _safeSearchAlbums("trending punjabi album"),

      // Trending Hindi
      _safeSearchPlaylist("trending hindi playlist"),
      _safeSearchAlbums("trending hindi album"),

      // Trending English
      _safeSearchPlaylist("trending english playlist"),

      // Trending Phonk
      _safeSearchPlaylist("phonk playlist"),
      _safeSearchAlbums("phonk album"),

      // Trending Brazilian Phonk
      _safeSearchPlaylist("brazilian phonk playlist"),
      _safeSearchAlbums("brazilian phonk album"),

      // Nonstop Mashup
      _safeSearchPlaylist("nonstop punjabi mashup"),
      _safeSearchPlaylist("nonstop hindi mashup"),
      _safeSearchPlaylist("nonstop english mashup"),
    ]);

    return (
      quickPicks: quickPicks,
      playlist: playlist,
      albums: albums,
      globalHitsPlaylists: trendingResults[0],
      trendingGloballyPlaylists: trendingResults[1],
      trendingPunjabiPlaylists: trendingResults[2],
      trendingPunjabiAlbums: trendingResults[3],
      trendingHindiPlaylists: trendingResults[4],
      trendingHindiAlbums: trendingResults[5],
      trendingEnglishPlaylists: trendingResults[6],
      trendingPhonkPlaylists: trendingResults[7],
      trendingPhonkAlbums: trendingResults[8],
      trendingBrazilianPhonkPlaylists: trendingResults[9],
      trendingBrazilianPhonkAlbums: trendingResults[10],
      nonstopPunjabiMashup: trendingResults[11],
      nonstopHindiMashup: trendingResults[12],
      nonstopEnglishMashup: trendingResults[13],
    );
  }

  // Safe wrapper for playlist search - returns empty list on error
  Future<List<PlayListmodel>> _safeSearchPlaylist(String query) async {
    try {
      final playlists = await _dataProvider.searchPlaylist(query);
      return RepositoryHelperFunction.getPlaylistDetailedToPlayListModel(
          playlists);
    } catch (e) {
      return [];
    }
  }

  // Safe wrapper for album search - returns empty list on error
  Future<List<PlayListmodel>> _safeSearchAlbums(String query) async {
    try {
      final albums = await _dataProvider.searchAlbums(query);
      return RepositoryHelperFunction.albumsToPlaylist(albums);
    } catch (e) {
      return [];
    }
  }


Future<
    ({
      List<Songmodel> playlistSongs,
      int playlistSize,
      String playListDuration
    })> getPlayList(
  String playlistId,
  int index,
) async {
  // 1️⃣ Get song IDs stream
  final songStream =
      await _dataProvider.getSongIdFromPlayList(playlistId).toList();

  final totalSongs = songStream.length;

  // 2️⃣ Prepare IDs & durations
  final songIds =
      songStream.skip(index).map((video) => video.id.value).take(20).toList();

  final songsDuration = songStream
      .skip(index)
      .map((video) => video.duration!.inSeconds)
      .take(20)
      .toList();

  // 3️⃣ Fetch songs (NETWORK / MAIN ISOLATE)
  final songsList = await _dataProvider.getPlayListSongs(songIds);

  // 4️⃣ CPU-heavy mapping in isolate
  final playlistSongs = await compute(
    playlistSongsCompute,
    (
      songs: songsList,
      durations: songsDuration,
    ),
  );

  return (
    playlistSongs: playlistSongs,
    playlistSize: totalSongs,
    playListDuration: "",
  );
}


  //###########

//play get song [Deep link]
  Future<Songmodel> getSongDataDeeplink(String songId) async {
    final data = await Future.wait([
      _dataProvider.getSongForDeeplinkSearchSong(songId),
      _dataProvider.getSongForDeeplinkSearchVideo(songId),
    ]);
    final songFull = data[0] as SongFull;
    final videoFull = data[1] as VideoFull;

    if (songFull.videoId.isNotEmpty) {
      return RepositoryHelperFunction.convertSongFullToSongModel(songFull);
    }
    return RepositoryHelperFunction.convertVideoFullToSongModel(videoFull);
  }

  Future<SongRawData> getSongUrl(String songId, AudioQuality quality) async {
    final manifest = await _dataProvider.songStreamUrl(songId);

    final audioStreams = manifest.audioOnly;

    final totalbytes = audioStreams.withHighestBitrate().size.totalBytes;
    final selectedStream =
        RepositoryHelperFunction.selectStream(audioStreams, quality);
    final audioCodecs =
        RepositoryHelperFunction.audioCodecsFormate(audioStreams);

    return SongRawData(
        url: selectedStream.url, codecs: audioCodecs, totalBytes: totalbytes);
  }

  //Search suggestion
  Future<List<String>> searchSuggetion(String query) async {
    return await _dataProvider.searchSuggestion(query);
  }

//seach in songs
  Future<List<Songmodel>> searchSong(String inputText) async {
    final quality = _dbInstance.getData;

    final searchResults = await _dataProvider.searchSong(inputText);
    List<Songmodel> songs = [];
    for (var i = 0; i < searchResults.length; i++) {
      final song = searchResults[i];
      songs.add(
        Songmodel(
          vId: song.videoId,
          songName: song.name,
          artist: song.artist,
          thumbnail: quality.thumbnailQuality == ThumbnailQuality.low
              ? getThumbnail(song.thumbnails)
              : await getThumbnailUsingUrl(song.videoId),
          duration: timeFormate(song.duration ?? 0),
        ),
      );
    }
    return songs;
  }

  //search in videos
  Future<List<Songmodel>> searchVideo(String inputText) async {
    final searchResults = await _dataProvider.searchVideo(inputText);
    List<Songmodel> songs = [];
    for (var i = 0; i < searchResults.length; i++) {
      final song = searchResults[i];
      songs.add(
        Songmodel(
          vId: song.videoId,
          songName: song.name,
          artist: song.artist,
          thumbnail: getThumbnail(song.thumbnails),
          duration: timeFormate(song.duration ?? 0),
        ),
      );
    }
    return songs;
  }

  //search In playlists
  Future<List<PlayListmodel>> searchPlaylist(String inputText) async {
    final playlists = await _dataProvider.searchPlaylist(inputText);
    return RepositoryHelperFunction.getPlaylistDetailedToPlayListModel(
        playlists);
  }

  //search artist
  Future<List<ArtistModel>> searchArtist(String inputText) async {
    final artists = await _dataProvider.searchArtist(inputText);
    return RepositoryHelperFunction.getArtist(artists);
  }

  //get artist Songs
  Future<List<Songmodel>> getArtistSongs(String artistId) async {
    final quality = _dbInstance.getData;

    final artistSongs = await _dataProvider.getArtistSongs(artistId);
    return RepositoryHelperFunction.getQuickPicks(
        artistSongs, quality.thumbnailQuality);
  }

//search albums
  Future<List<PlayListmodel>> searchAlbums(String inputText) async {
    final albums = await _dataProvider.searchAlbums(inputText);
    return RepositoryHelperFunction.albumsToPlaylist(albums);
  }

  //get artist album
  Future<List<PlayListmodel>> getArtistAlbums(ArtistModel artist) async {
    List<AlbumDetailed> albums =
        await _dataProvider.getArtistAlbums(artist.artist.artistId ?? "");

    return RepositoryHelperFunction.albumsToPlaylist(albums);
  }

  //get radio songs (similar songs)
  Future<List<Songmodel>> getRadioSongs(String videoId) async {
    final radioSongsRaw = await _dataProvider.getUpNexts(videoId);
    return RepositoryHelperFunction.convertUpNextsDetailsListToSongModelList(
        radioSongsRaw);
  }
}

//Isolate
/// Isolate-safe payload
typedef _PlaylistComputePayload = ({
  List<SongFull> songs,
  List<int> durations,
});

/// Top-level function for compute
// ignore: library_private_types_in_public_api
List<Songmodel> playlistSongsCompute(_PlaylistComputePayload payload) {
  return RepositoryHelperFunction.getSongsList(
    payload.songs,
    payload.durations,
  );
}