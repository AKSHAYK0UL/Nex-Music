import 'dart:async';
import 'package:dart_ytmusic_api/types.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/helper_function/repository/repository_helper_function.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/cdn_cache_model.dart';
import 'package:nex_music/model/lyric_model.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:nex_music/repository/cdn_cache_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Repository {
  // ignore: unused_field
  final YoutubeExplode _yt;
  final DataProvider _dataProvider;
  final HiveDataBaseSingleton _dbInstance;
  final Map<String, LyricModel> _lyricsCache = {};
  String? _activePlaylistId;
  List<Songmodel> _activePlaylistSongs = [];

  // Optional CDN cache repository injected only when the CDN feature is
  // enabled.  When null every call falls back to the regular YouTube path.
  CdnCacheRepository? cdnCacheRepository;

  Repository(
      {required DataProvider dataProvider,
      required YoutubeExplode yt,
      required HiveDataBaseSingleton dbInstance,
      this.cdnCacheRepository})
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

  final Map<String, LyricModel> _ytLyricsCache = {};
  final Map<String, LyricModel> _lrclibLyricsCache = {};

  Future<LyricModel?> getLyricsYtOnly({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    if (_ytLyricsCache.containsKey(videoId)) return _ytLyricsCache[videoId];
    final lyrics = await _dataProvider.getLyricsYtOnly(
      title: title,
      artist: artist,
      videoId: videoId,
      durationSeconds: durationSeconds,
    );
    if (lyrics != null) _ytLyricsCache[videoId] = lyrics;
    return lyrics;
  }

  Future<LyricModel?> getLyricsLrclibOnly({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    if (_lrclibLyricsCache.containsKey(videoId)) {
      return _lrclibLyricsCache[videoId];
    }
    final lyrics = await _dataProvider.getLyricsLrclibOnly(
      title: title,
      artist: artist,
      durationSeconds: durationSeconds,
    );
    if (lyrics != null) _lrclibLyricsCache[videoId] = lyrics;
    return lyrics;
  }

  // Fetches both YT Music and LRCLIB lyrics in parallel.
  // Returns a record of (ytLyrics, lrclibLyrics) either may be null.
  Future<({LyricModel? ytLyrics, LyricModel? lrclibLyrics})>
      fetchBothLyricsSources({
    required String title,
    required String artist,
    required String videoId,
    int? durationSeconds,
  }) async {
    final results = await Future.wait([
      getLyricsYtOnly(
        title: title,
        artist: artist,
        videoId: videoId,
        durationSeconds: durationSeconds,
      ).catchError((_) => null as LyricModel?),
      getLyricsLrclibOnly(
        title: title,
        artist: artist,
        videoId: videoId,
        durationSeconds: durationSeconds,
      ).catchError((_) => null as LyricModel?),
    ]);
    return (ytLyrics: results[0], lrclibLyrics: results[1]);
  }

//cancel all ongoing request
  void cancelRequest() {
    _dataProvider.cancelRequest();
  }

//using records
  Future<
      ({
        List<Songmodel> quickPicks,
        List<HomeSection> homeSections,
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

    // Fetch main home data (getHome(country:'IN')) + search-based quick picks in parallel
    final networkData = await _dataProvider.homeScreenSongs(inputPrompt);

    final homeSections = networkData.homeSectionData;

    //   Quick Picks
    // Prefer SongDetailed items from the top_picks / recommended section.
    // Fall back to the searchSongs result if no songs were found there.
    List<Songmodel> quickPicks = [];
    final topPicksSection = homeSections.firstWhere(
      (s) => s.stableTitle == 'top_picks' || s.stableTitle == 'recommended',
      orElse: () => HomeSection(title: '', stableTitle: '', contents: []),
    );
    final topPickSongs =
        topPicksSection.contents.whereType<SongDetailed>().toList();
    if (topPickSongs.isNotEmpty) {
      quickPicks = await RepositoryHelperFunction.getQuickPicks(
          topPickSongs, quality.thumbnailQuality);
    }
    // Fall back to search-based quick picks
    if (quickPicks.isEmpty) {
      quickPicks = await RepositoryHelperFunction.getQuickPicks(
          networkData.quickPicks, quality.thumbnailQuality);
    }

    //  Map HomeSection list to named fields by stableTitle
    // Helper: extract PlayListmodel list from a section's PlaylistDetailed contents
    List<PlayListmodel> playlistsFrom(HomeSection s) =>
        s.contents.whereType<PlaylistDetailed>().map((p) {
          final id = p.playlistId.isNotEmpty ? p.playlistId : p.playlistId;
          return PlayListmodel(
            playListId: id,
            playlistName: p.name,
            artistBasic: p.artist,
            thumbnail: getThumbnail(p.thumbnails),
          );
        }).toList();

    // Helper: extract PlayListmodel list from a section's AlbumDetailed contents
    List<PlayListmodel> albumsFrom(HomeSection s) =>
        s.contents.whereType<AlbumDetailed>().map((a) {
          return PlayListmodel(
            playListId: a.albumId.isNotEmpty ? a.albumId : a.playlistId,
            playlistName: a.name,
            artistBasic: a.artist,
            thumbnail: getThumbnail(a.thumbnails),
          );
        }).toList();

    // Helper: extract both playlists and album-like playlists from a section
    List<PlayListmodel> mixedPlaylistsFrom(HomeSection s) {
      final result = <PlayListmodel>[];
      for (final c in s.contents) {
        if (c is PlaylistDetailed) {
          result.add(PlayListmodel(
            playListId: c.playlistId,
            playlistName: c.name,
            artistBasic: c.artist,
            thumbnail: getThumbnail(c.thumbnails),
          ));
        } else if (c is AlbumDetailed) {
          result.add(PlayListmodel(
            playListId: c.albumId.isNotEmpty ? c.albumId : c.playlistId,
            playlistName: c.name,
            artistBasic: c.artist,
            thumbnail: getThumbnail(c.thumbnails),
          ));
        }
      }
      return result;
    }

    // Find first section matching one or more stable slugs
    HomeSection? findSection(List<String> slugs) {
      for (final s in homeSections) {
        if (slugs.contains(s.stableTitle)) return s;
      }
      return null;
    }

    // Find first section whose title contains any of the given keywords
    HomeSection? findByKeyword(List<String> keywords) {
      for (final s in homeSections) {
        final t = s.title.toLowerCase();
        if (keywords.any((k) => t.contains(k))) return s;
      }
      return null;
    }

    //  "Made For You" playlists (top_picks section playlists, or any playlist section)
    final madeForYouSection =
        findSection(['top_picks', 'recommended', 'mixed_for_you']) ??
            findByKeyword(['made for you', 'top pick', 'quick pick']);
    final playlist = madeForYouSection != null
        ? mixedPlaylistsFrom(madeForYouSection)
            .where((p) =>
                !p.playListId.startsWith('MPREb_') &&
                !p.playListId.startsWith('OLAK'))
            .toList()
        : RepositoryHelperFunction.getPlaylists(homeSections);

    //  Albums (new_releases or top_albums section)
    final albumSection = findSection(['new_releases', 'top_albums']) ??
        findByKeyword(['new release', 'top album', 'album', 'release']);
    final albums = albumSection != null
        ? albumsFrom(albumSection)
            .followedBy(playlistsFrom(albumSection).where((p) =>
                p.playListId.startsWith('MPREb_') ||
                p.playListId.startsWith('OLAK')))
            .toList()
        : RepositoryHelperFunction.getAlbums(homeSections);

    //  Trending / Charts sections
    final trendingSection = findSection(['trending', 'charts']) ??
        findByKeyword(['trending', 'chart', 'top song']);
    final globalHitsPlaylists = trendingSection != null
        ? mixedPlaylistsFrom(trendingSection)
        : <PlayListmodel>[];

    //  "Trending globally" second trending-like section, or empty
    final trendingSections = homeSections
        .where((s) => s.stableTitle == 'trending' || s.stableTitle == 'charts')
        .toList();
    final trendingGloballyPlaylists = trendingSections.length > 1
        ? mixedPlaylistsFrom(trendingSections[1])
        : <PlayListmodel>[];

    // Punjabi sections
    final punjabiSection = findByKeyword(['punjabi']);
    final trendingPunjabiPlaylists = punjabiSection != null
        ? playlistsFrom(punjabiSection)
        : <PlayListmodel>[];
    final trendingPunjabiAlbums =
        punjabiSection != null ? albumsFrom(punjabiSection) : <PlayListmodel>[];

    //  Hindi sections
    final hindiSection = findByKeyword(['hindi']);
    final trendingHindiPlaylists =
        hindiSection != null ? playlistsFrom(hindiSection) : <PlayListmodel>[];
    final trendingHindiAlbums =
        hindiSection != null ? albumsFrom(hindiSection) : <PlayListmodel>[];

    //  English sections
    final englishSection = findByKeyword(['english']);
    final trendingEnglishPlaylists = englishSection != null
        ? playlistsFrom(englishSection)
        : <PlayListmodel>[];

    //  Phonk sections
    final phonkSection = findByKeyword(['phonk']);
    final trendingPhonkPlaylists =
        phonkSection != null ? playlistsFrom(phonkSection) : <PlayListmodel>[];
    final trendingPhonkAlbums =
        phonkSection != null ? albumsFrom(phonkSection) : <PlayListmodel>[];

    //  Brazilian Phonk sections
    final brazilianPhonkSection =
        findByKeyword(['brazilian phonk', 'brazil phonk']);
    final trendingBrazilianPhonkPlaylists = brazilianPhonkSection != null
        ? playlistsFrom(brazilianPhonkSection)
        : <PlayListmodel>[];
    final trendingBrazilianPhonkAlbums = brazilianPhonkSection != null
        ? albumsFrom(brazilianPhonkSection)
        : <PlayListmodel>[];

    //  Mashup sections
    final punjabiMashupSection =
        findByKeyword(['punjabi mashup', 'nonstop punjabi']);
    final nonstopPunjabiMashup = punjabiMashupSection != null
        ? mixedPlaylistsFrom(punjabiMashupSection)
        : <PlayListmodel>[];

    final hindiMashupSection = findByKeyword(['hindi mashup', 'nonstop hindi']);
    final nonstopHindiMashup = hindiMashupSection != null
        ? mixedPlaylistsFrom(hindiMashupSection)
        : <PlayListmodel>[];

    final englishMashupSection =
        findByKeyword(['english mashup', 'nonstop english']);
    final nonstopEnglishMashup = englishMashupSection != null
        ? mixedPlaylistsFrom(englishMashupSection)
        : <PlayListmodel>[];

    return (
      quickPicks: quickPicks,
      homeSections: homeSections,
      playlist: playlist,
      albums: albums,
      globalHitsPlaylists: globalHitsPlaylists,
      trendingGloballyPlaylists: trendingGloballyPlaylists,
      trendingPunjabiPlaylists: trendingPunjabiPlaylists,
      trendingPunjabiAlbums: trendingPunjabiAlbums,
      trendingHindiPlaylists: trendingHindiPlaylists,
      trendingHindiAlbums: trendingHindiAlbums,
      trendingEnglishPlaylists: trendingEnglishPlaylists,
      trendingPhonkPlaylists: trendingPhonkPlaylists,
      trendingPhonkAlbums: trendingPhonkAlbums,
      trendingBrazilianPhonkPlaylists: trendingBrazilianPhonkPlaylists,
      trendingBrazilianPhonkAlbums: trendingBrazilianPhonkAlbums,
      nonstopPunjabiMashup: nonstopPunjabiMashup,
      nonstopHindiMashup: nonstopHindiMashup,
      nonstopEnglishMashup: nonstopEnglishMashup,
    );
  }

  Future<
      ({
        List<Songmodel> playlistSongs,
        int playlistSize,
        String playListDuration
      })> getPlayList(
    String playlistId,
    int index, {
    bool isAlbum = false,
  }) async {
    // Fast path: if the playlist songs are already in memory and index is within cached range
    if (_activePlaylistId == playlistId &&
        _activePlaylistSongs.isNotEmpty &&
        index < _activePlaylistSongs.length) {
      final pagedSongs = _activePlaylistSongs.skip(index).take(20).toList();
      return (
        playlistSongs: pagedSongs,
        playlistSize: _activePlaylistSongs.length,
        playListDuration: "",
      );
    }

    debugPrint(
        "##################### FETCHING ${isAlbum ? 'ALBUM' : 'PLAYLIST'} $playlistId (index=$index) ##############################");

    try {
      if (isAlbum) {
        // Fetch Album via dart_ytmusic_api
        final album = await _dataProvider.getAlbum(playlistId);
        final allSongs =
            RepositoryHelperFunction.convertSongDetailedListToSongModelList(
          album.songs,
        );
        _activePlaylistId = playlistId;
        _activePlaylistSongs = allSongs;
        final pagedSongs = allSongs.skip(index).take(20).toList();
        return (
          playlistSongs: pagedSongs,
          playlistSize: allSongs.length,
          playListDuration: "",
        );
      } else {
        // Fetch Playlist via dart_ytmusic_api (getPlaylistVideos)
        final playlistVideos =
            await _dataProvider.getPlaylistVideos(playlistId);
        final allSongs =
            RepositoryHelperFunction.convertVideoDetailedListToSongModelList(
          playlistVideos,
        );
        _activePlaylistId = playlistId;
        _activePlaylistSongs = allSongs;
        final pagedSongs = allSongs.skip(index).take(20).toList();
        return (
          playlistSongs: pagedSongs,
          playlistSize: allSongs.length,
          playListDuration: "",
        );
      }
    } catch (e) {
      debugPrint('[Repository] Failed to fetch via ytMusic: $e');
      if (isAlbum) {
        try {
          final playlistVideos =
              await _dataProvider.getPlaylistVideos(playlistId);
          final allSongs =
              RepositoryHelperFunction.convertVideoDetailedListToSongModelList(
            playlistVideos,
          );
          _activePlaylistId = playlistId;
          _activePlaylistSongs = allSongs;
          final pagedSongs = allSongs.skip(index).take(20).toList();
          return (
            playlistSongs: pagedSongs,
            playlistSize: allSongs.length,
            playListDuration: "",
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  //  CDN aware playlist/album loader

  // Loads a playlist or album using the CDN cache-first strategy when the

  Future<
      ({
        List<Songmodel> playlistSongs,
        int playlistSize,
        String playListDuration,
        bool fromCache,
      })> getPlayListWithCdn(
    String playlistId,
    int index, {
    required String playlistName,
    required bool isAlbum,
  }) async {
    final cdn = cdnCacheRepository;

    // CDN disabled or unavailable straight YouTube path.
    if (cdn == null || !_dbInstance.cdnEnabled) {
      final result = await getPlayList(playlistId, index, isAlbum: isAlbum);
      return (
        playlistSongs: result.playlistSongs,
        playlistSize: result.playlistSize,
        playListDuration: result.playListDuration,
        fromCache: false,
      );
    }

    // Pagination pages beyond 0: CDN is not involved (songs already loaded).
    if (index > 0) {
      final result = await getPlayList(playlistId, index, isAlbum: isAlbum);
      return (
        playlistSongs: result.playlistSongs,
        playlistSize: result.playlistSize,
        playListDuration: result.playListDuration,
        fromCache: false,
      );
    }

    // CDN lookup for first page.
    CdnCacheModel? cacheEntry;
    try {
      cacheEntry = await cdn.getFromCache(playlistId, isAlbum: isAlbum);
    } catch (_) {
      cacheEntry = null;
    }

    //  cache hit, entry is fresh (< 48 h).
    if (cacheEntry != null && !cacheEntry.isExpired()) {
      debugPrint(
          '[Repository] CDN HIT $playlistId (${cacheEntry.songs.length} songs). Background sync scheduled.');
      final cachedSongs = List<Songmodel>.unmodifiable(cacheEntry.songs);
      unawaited(cdn.backgroundSync(
        playlistId,
        isAlbum: isAlbum,
        cachedSongs: cachedSongs,
        ytFetcher: () => _fetchAllSongsFromYt(playlistId, isAlbum: isAlbum),
      ));
      return (
        playlistSongs: cacheEntry.songs,
        playlistSize: cacheEntry.songs.length,
        playListDuration: '',
        fromCache: true,
      );
    }

    // cache hit but expired.
    if (cacheEntry != null && cacheEntry.isExpired()) {
      debugPrint('[Repository] CDN EXPIRED $playlistId. Fetching fresh data.');
      try {
        final allSongs =
            await _fetchAllSongsFromYt(playlistId, isAlbum: isAlbum);
        if (allSongs.isNotEmpty) {
          unawaited(cdn.updateCache(playlistId, allSongs, isAlbum: isAlbum));
        }
        return (
          playlistSongs: allSongs,
          playlistSize: allSongs.length,
          playListDuration: '',
          fromCache: false,
        );
      } catch (e) {
        // YT failed  gracefully fall back to stale cache.
        debugPrint(
            '[Repository] CDN expired refresh failed, using stale data: $e');
        return (
          playlistSongs: cacheEntry.songs,
          playlistSize: cacheEntry.songs.length,
          playListDuration: '',
          fromCache: true,
        );
      }
    }

    //  no cache entry  fetch from YouTube, save to CDN in background.
    debugPrint('[Repository] CDN MISS $playlistId. Fetching from YouTube.');
    final result = await getPlayList(playlistId, 0, isAlbum: isAlbum);
    unawaited(_fetchAllAndSaveToCdn(
      playlistId: playlistId,
      playlistName: playlistName,
      isAlbum: isAlbum,
      cdn: cdn,
    ));
    return (
      playlistSongs: result.playlistSongs,
      playlistSize: result.playlistSize,
      playListDuration: result.playListDuration,
      fromCache: false,
    );
  }

  // Fetches the **complete** song list from YouTube (all pages, no limit).
  // Used by CDN cache writes and background sync.
  Future<List<Songmodel>> _fetchAllSongsFromYt(
    String playlistId, {
    bool isAlbum = false,
  }) async {
    try {
      if (isAlbum) {
        final album = await _dataProvider.getAlbum(playlistId);
        return RepositoryHelperFunction.convertSongDetailedListToSongModelList(
          album.songs,
        );
      } else {
        final playlistVideos =
            await _dataProvider.getPlaylistVideos(playlistId);
        return RepositoryHelperFunction.convertVideoDetailedListToSongModelList(
          playlistVideos,
        );
      }
    } catch (e) {
      debugPrint('[Repository] _fetchAllSongsFromYt ytMusic failed: $e');
      if (isAlbum) {
        try {
          final playlistVideos =
              await _dataProvider.getPlaylistVideos(playlistId);
          return RepositoryHelperFunction
              .convertVideoDetailedListToSongModelList(
            playlistVideos,
          );
        } catch (_) {}
      }
      return [];
    }
  }

  // Fetches all songs and saves them to the CDN. Fire-and-forget
  Future<void> _fetchAllAndSaveToCdn({
    required String playlistId,
    required String playlistName,
    required bool isAlbum,
    required CdnCacheRepository cdn,
  }) async {
    try {
      final allSongs = await _fetchAllSongsFromYt(playlistId, isAlbum: isAlbum);
      if (allSongs.isNotEmpty) {
        await cdn.saveToCache(playlistId, playlistName, allSongs,
            isAlbum: isAlbum);
      }
    } catch (e) {
      debugPrint('[Repository] _fetchAllAndSaveToCdn failed (suppressed): $e');
    }
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
    final nameKey = (artistName ?? '').trim().toLowerCase();
    if (artistId != null &&
        artistId.isNotEmpty &&
        _artistDetailsCache.containsKey(artistId)) {
      final cached = _artistDetailsCache[artistId];
      if (cached != null) {
        final cachedName = cached.artist.name.trim().toLowerCase();
        if (nameKey.isEmpty ||
            cachedName == nameKey ||
            cachedName.contains(nameKey) ||
            nameKey.contains(cachedName)) {
          return cached;
        }
      }
    }
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

    final nameKey = artistName.toLowerCase();

    // Check cache first
    if (artistId != null &&
        artistId.isNotEmpty &&
        _artistDetailsCache.containsKey(artistId)) {
      final cached = _artistDetailsCache[artistId]!;
      final cachedName = cached.artist.name.trim().toLowerCase();
      if (nameKey.isEmpty ||
          cachedName == nameKey ||
          cachedName.contains(nameKey) ||
          nameKey.contains(cachedName)) {
        return cached;
      }
    }
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
        final fullNameLower = full.name.trim().toLowerCase();
        // Verify full.name actually matches artistName (not a record label channel like T-Series or Speed Records)
        final isNameMatch = nameKey.isEmpty ||
            fullNameLower == nameKey ||
            fullNameLower.contains(nameKey) ||
            nameKey.contains(fullNameLower);

        if (isNameMatch && full.thumbnails.isNotEmpty) {
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

    // If artistId was missing, invalid, or belonged to a label rather than the artist, search by name
    if (artistName.isNotEmpty) {
      try {
        final searched = await searchArtist(artistName);
        if (searched.isNotEmpty) {
          // Find an artist in search results whose name actually matches
          ArtistModel? match;
          for (final a in searched) {
            final aNameLower = a.artist.name.trim().toLowerCase();
            if (aNameLower == nameKey ||
                aNameLower.contains(nameKey) ||
                nameKey.contains(aNameLower)) {
              match = a;
              break;
            }
          }

          if (match != null && match.thumbnail.isNotEmpty) {
            final resolved = ArtistModel(
              artist: ArtistBasic(
                name: match.artist.name,
                artistId: match.artist.artistId,
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
