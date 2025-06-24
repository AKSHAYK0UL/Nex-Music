import 'package:dart_ytmusic_api/types.dart';
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
  Future<({List<Songmodel> quickPicks, List<PlayListmodel> playlist})>
      homeScreenSongsList(String inputPrompt) async {
    final quality = _dbInstance.getData;
    final networkData = await _dataProvider.homeScreenSongs(inputPrompt);
    final quickPicks = await RepositoryHelperFunction.getQuickPicks(
        networkData.quickPicks, quality.thumbnailQuality);
    final playlist =
        RepositoryHelperFunction.getPlaylists(networkData.homeSectionData);

    return (quickPicks: quickPicks, playlist: playlist);
  }

  //Get playlist songs
  Future<
      ({
        List<Songmodel> playlistSongs,
        int playlistSize,
        String playListDuration
      })> getPlayList(
    String playlistId,
    int index,
  ) async {
    final songStream =
        await _dataProvider.getSongIdFromPlayList(playlistId).toList();
    int totalSongs = songStream.length;

    List<String> songIds =
        songStream.skip(index).map((video) => video.id.value).take(20).toList();

    List<int> songsDuration = songStream
        .skip(index)
        .map((video) => video.duration!.inSeconds)
        .take(20)
        .toList();

    int totalDurationInSeconds = songStream
        .map((video) => video.duration?.inSeconds ?? 0)
        .fold(0, (total, duration) => total + duration);

    String playListDuration = timeFormate(totalDurationInSeconds);

    final songsList = await _dataProvider.getPlayListSongs(songIds);

    return (
      playlistSongs:
          RepositoryHelperFunction.getSongsList(songsList, songsDuration),
      playlistSize: totalSongs,
      playListDuration: playListDuration,
    );
  }

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

    print("STREAM BITRATE : ${selectedStream.bitrate.kiloBitsPerSecond}");
    print(
        "audioStreams.withHighestBitrate() ${audioStreams.withHighestBitrate().bitrate.kiloBitsPerSecond} @@@@@@@@@2");
    return SongRawData(
        url: selectedStream.url, codecs: audioCodecs, totalBytes: totalbytes);
  }

  // Future<Uri> getSongUrl(String songId, AudioQuality quality) async {
  //   final manifest = await _dataProvider.songStreamUrl(songId);
  //   final audioStreams = manifest.audioOnly;
  //   // for (var stream in audioStreams) {
  //   //   // print("SONG CODEC ${stream.container.name}");
  //   //   // print("SONG QualityLabel ${stream.qualityLabel}");
  //   //   print('Codec: ${stream.audioCodec}');
  //   //   print('Container: ${stream.container.name}');
  //   // print('Bitrate: ${stream.bitrate.kiloBitsPerSecond} kbps');
  //   // }

  //   // Select the stream based on the desired quality.
  //   final selectedStream =
  //       RepositoryHelperFunction.selectStream(audioStreams, quality);
  //   final audioCodecs =
  //       RepositoryHelperFunction.audioCodecsFormate(audioStreams);
  //   print("STREAM BITRATE : ${selectedStream.bitrate.kiloBitsPerSecond}");

  //   return selectedStream.url;
  // }

  //Search suggestion
  Future<List<String>> searchSuggetion(String query) async {
    return await _dataProvider.searchSuggestion(query);
  }

//seach in songs
  Future<List<Songmodel>> searchSong(String inputText) async {
    final quality = await _dbInstance.getData;

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
    final quality = await _dbInstance.getData;

    final artistSongs = await _dataProvider.getArtistSongs(artistId);
    return RepositoryHelperFunction.getQuickPicks(
        artistSongs, quality.thumbnailQuality);
  }

  //get artist album
  Future<List<PlayListmodel>> getArtistAlbums(String artistId) async {
    final albums = await _dataProvider.getArtistAlbums(artistId);
    return RepositoryHelperFunction.albumsToPlaylist(albums);
  }
}
