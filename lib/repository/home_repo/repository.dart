import 'package:dart_ytmusic_api/types.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/helper_function/repository/repository_helper_function.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Repository {
  final YoutubeExplode _yt;
  final DataProvider _dataProvider;
  final HiveDataBaseSingleton _dbInstance;
  final Map<String, LyricModel> _lyricsCache = {};

  Repository(
      {required DataProvider dataProvider,
      required YoutubeExplode yt,
      required HiveDataBaseSingleton dbInstance})
      : _dataProvider = dataProvider,
        _yt = yt,
        _dbInstance = dbInstance;

  Future<LyricModel?> getLyrics({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    if (_lyricsCache.containsKey(videoId)) {
      return _lyricsCache[videoId];
    }
    final lyrics = await _dataProvider.getLyrics(
      title: title,
      artist: artist,
      videoId: videoId,
      durationSeconds: durationSeconds,
    );
    if (lyrics != null) {
      _lyricsCache[videoId] = lyrics;
    }
    return lyrics;
  }

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
    print(
        "##################### SONG PLAYLISTID ${playlistId} ##############################");

    // Get song IDs stream

    // final songStream =
    //     await _dataProvider.getSongIdFromPlayList(playlistId).toList();
    final songStream = await _dataProvider.getSongIdFromPlayList(playlistId);

    print(
        "##################### SONG STREAMs ${songStream} ##############################");
    final totalSongs = songStream.length;

    // 2️ Prepare IDs & durations
    final songIds =
        songStream.skip(index).map((video) => video.videoId).take(20).toList();
    print(
        "##################### SONG IDS ${songIds} ##############################");

    final songsDuration = songStream
        .skip(index)
        .map((video) => video.duration!.inSeconds)
        .take(20)
        .toList();

    // 3️ Fetch songs (NETWORK / MAIN ISOLATE)
    final songsList = await _dataProvider.getPlayListSongs(songIds);

    // 4️ CPU-heavy mapping in isolate
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

  final Map<String, ({SongRawData data, DateTime expiresAt})> _songUrlCache =
      {};

  Future<SongRawData> getSongUrl(String songId, AudioQuality quality) async {
    final cacheKey = '$songId-${quality.name}';
    final cached = _songUrlCache[cacheKey];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.data;
    }

    final manifest = await _dataProvider.songStreamUrl(songId);

    final audioStreams = manifest.audioOnly;

    final totalbytes = audioStreams.withHighestBitrate().size.totalBytes;
    final selectedStream =
        RepositoryHelperFunction.selectStream(audioStreams, quality);
    final audioCodecs =
        RepositoryHelperFunction.audioCodecsFormate(audioStreams);

    final rawData = SongRawData(
        url: selectedStream.url, codecs: audioCodecs, totalBytes: totalbytes);

    if (_songUrlCache.length > 50) {
      _songUrlCache.remove(_songUrlCache.keys.first);
    }
    _songUrlCache[cacheKey] = (
      data: rawData,
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    );

    return rawData;
  }

  // Preload a song URL into the memory cache in the background
  void preloadSongUrl(String songId, AudioQuality quality) {
    final cacheKey = '$songId-${quality.name}';
    if (_songUrlCache.containsKey(cacheKey)) return;
    getSongUrl(songId, quality).then((_) {}, onError: (_) {});
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
          thumbnail: getThumbnail(song.thumbnails, quality.thumbnailQuality),
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

  // In-memory cache for resolved artist details
  final Map<String, ArtistModel> _artistDetailsCache = {};

  ArtistModel? getCachedArtist(String? artistId, String? artistName) {
    if (artistId != null &&
        artistId.isNotEmpty &&
        _artistDetailsCache.containsKey(artistId)) {
      return _artistDetailsCache[artistId];
    }
    final nameKey = (artistName ?? '').trim().toLowerCase();
    if (nameKey.isNotEmpty && _artistDetailsCache.containsKey(nameKey)) {
      return _artistDetailsCache[nameKey];
    }
    return null;
  }

  // Get artist full details
  Future<ArtistFull> getArtist(String artistId) async {
    return await _dataProvider.getArtist(artistId);
  }

  //search artist
  Future<List<ArtistModel>> searchArtist(String inputText) async {
    final artists = await _dataProvider.searchArtist(inputText);
    final artistModels = RepositoryHelperFunction.getArtist(artists);
    for (final a in artistModels) {
      if (a.artist.artistId != null && a.artist.artistId!.isNotEmpty) {
        _artistDetailsCache[a.artist.artistId!] = a;
      }
      _artistDetailsCache[a.artist.name.trim().toLowerCase()] = a;
    }
    return artistModels;
  }

  // Resolve artist model with real artist thumbnail and artistId
  Future<ArtistModel> resolveArtist(ArtistModel artist) async {
    final artistId = artist.artist.artistId;
    final artistName = artist.artist.name.trim();

    // Check cache first
    if (artistId != null &&
        artistId.isNotEmpty &&
        _artistDetailsCache.containsKey(artistId)) {
      return _artistDetailsCache[artistId]!;
    }
    final nameKey = artistName.toLowerCase();
    if (nameKey.isNotEmpty && _artistDetailsCache.containsKey(nameKey)) {
      return _artistDetailsCache[nameKey]!;
    }

    String? resolvedId = artistId;
    String? resolvedThumbnail =
        artist.thumbnail.isNotEmpty ? artist.thumbnail : null;

    //  If artistId is present, try getting artist profile to get their official high-res image
    if (resolvedId != null && resolvedId.isNotEmpty) {
      try {
        final full = await _dataProvider.getArtist(resolvedId);
        if (full.thumbnails.isNotEmpty) {
          final thumb = getThumbnail(full.thumbnails);
          if (thumb.isNotEmpty) {
            final resolved = ArtistModel(
              artist: ArtistBasic(name: full.name, artistId: full.artistId),
              thumbnail: thumb,
            );
            _artistDetailsCache[resolvedId] = resolved;
            if (nameKey.isNotEmpty) _artistDetailsCache[nameKey] = resolved;
            return resolved;
          }
        }
      } catch (_) {}
    }

    //  If artistId is missing or getArtist failed, search the artist by name
    if (artistName.isNotEmpty) {
      try {
        final searched = await searchArtist(artistName);
        if (searched.isNotEmpty) {
          final match = searched.firstWhere(
            (a) => a.artist.name.trim().toLowerCase() == nameKey,
            orElse: () => searched.first,
          );
          if (match.thumbnail.isNotEmpty) {
            final resolved = ArtistModel(
              artist: ArtistBasic(
                name: match.artist.name,
                artistId: match.artist.artistId ?? resolvedId,
              ),
              thumbnail: match.thumbnail,
            );
            if (resolved.artist.artistId != null &&
                resolved.artist.artistId!.isNotEmpty) {
              _artistDetailsCache[resolved.artist.artistId!] = resolved;
            }
            if (nameKey.isNotEmpty) _artistDetailsCache[nameKey] = resolved;
            return resolved;
          }
        }
      } catch (_) {}
    }

    return ArtistModel(
      artist: ArtistBasic(name: artistName, artistId: resolvedId),
      thumbnail: resolvedThumbnail ?? "",
    );
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
    final artistId = artist.artist.artistId;
    final artistName = artist.artist.name.trim();

    // Fetch artist profile (topAlbums & topSingles),
    // singles, and searchAlbums concurrently for maximum speed
    final discographyAlbumsFuture = (artistId != null && artistId.isNotEmpty)
        ? _dataProvider
            .getArtistAlbums(artistId)
            .catchError((_) => <AlbumDetailed>[])
        : Future.value(<AlbumDetailed>[]);

    final artistFullFuture = (artistId != null && artistId.isNotEmpty)
        ? _dataProvider
            .getArtist(artistId)
            .then<ArtistFull?>((v) => v)
            .catchError((_) => null)
        : Future.value(null);

    final discographySinglesFuture = (artistId != null && artistId.isNotEmpty)
        ? _dataProvider
            .getArtistSingles(artistId)
            .catchError((_) => <AlbumDetailed>[])
        : Future.value(<AlbumDetailed>[]);

    final searchAlbumsFuture = artistName.isNotEmpty
        ? _dataProvider
            .searchAlbums(artistName)
            .catchError((_) => <AlbumDetailed>[])
        : Future.value(<AlbumDetailed>[]);

    final results = await Future.wait([
      discographyAlbumsFuture,
      artistFullFuture,
      discographySinglesFuture,
      searchAlbumsFuture,
    ]);

    final discographyAlbums = results[0] as List<AlbumDetailed>;
    final artistFull = results[1] as ArtistFull?;
    final discographySingles = results[2] as List<AlbumDetailed>;
    final searchedAlbums = results[3] as List<AlbumDetailed>;

    final List<AlbumDetailed> allAlbums = [];
    final Set<String> seenIds = {};
    final Set<String> seenNames = {};

    void addAlbum(AlbumDetailed album) {
      if (album.playlistId.isNotEmpty && seenIds.contains(album.playlistId)) {
        return;
      }
      if (album.albumId.isNotEmpty && seenIds.contains(album.albumId)) {
        return;
      }

      final normName = album.name.trim().toLowerCase();
      if (normName.isNotEmpty && seenNames.contains(normName)) {
        return;
      }

      if (album.playlistId.isNotEmpty) seenIds.add(album.playlistId);
      if (album.albumId.isNotEmpty) seenIds.add(album.albumId);
      if (normName.isNotEmpty) seenNames.add(normName);

      allAlbums.add(album);
    }

    // albums from discography endpoint (for artists > 10 albums)
    for (final album in discographyAlbums) {
      addAlbum(album);
    }

    //  topAlbums from the artist profile carousel (especially for artists <= 10 albums)
    if (artistFull != null) {
      for (final album in artistFull.topAlbums) {
        addAlbum(album);
      }
    }

    // singles & EPs from discography endpoint
    for (final album in discographySingles) {
      addAlbum(album);
    }

    // Top singles & EPs from artist profile
    if (artistFull != null) {
      for (final album in artistFull.topSingles) {
        addAlbum(album);
      }
    }

    //  All matching albums & singles returned by searchAlbums
    final artistNameLower = artistName.toLowerCase();
    for (final album in searchedAlbums) {
      final albArtist = album.artist.name.trim().toLowerCase();
      if (albArtist == artistNameLower ||
          albArtist.contains(artistNameLower) ||
          artistNameLower.contains(albArtist)) {
        addAlbum(album);
      }
    }

    // If still empty ( artist with no exact matches) accept all searchedAlbums
    if (allAlbums.isEmpty && searchedAlbums.isNotEmpty) {
      for (final album in searchedAlbums) {
        addAlbum(album);
      }
    }

    return RepositoryHelperFunction.albumsToPlaylist(allAlbums);
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
