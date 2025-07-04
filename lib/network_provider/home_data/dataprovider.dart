import 'package:dart_ytmusic_api/types.dart' as yt;
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DataProvider {
  final YTMusic _ytMusic;
  final YoutubeExplode _youtubeExplode;

  DataProvider({
    required YTMusic ytMusic,
    required YoutubeExplode youtubeExplode,
  })  : _ytMusic = ytMusic,
        _youtubeExplode = youtubeExplode;

//cancel all ongoing request
  void cancelRequest() {
    _ytMusic.dio.close();
    _youtubeExplode.close();
  }

  //get home section data
  Future<
      ({
        List<yt.HomeSection> homeSectionData,
        List<yt.SongDetailed> quickPicks
      })> homeScreenSongs(String inputPrompt) async {
    await _ytMusic.initialize();
    final fetchedData = await Future.wait(
      [
        _ytMusic.getHomeSections(),
        _ytMusic.searchSongs(inputPrompt),
      ],
    );

    final homeSectionData =
        fetchedData[0] as List<yt.HomeSection>; //PlayList, Album
    final quickPicks = fetchedData[1] as List<yt.SongDetailed>; ////Quick Picks

    return (homeSectionData: homeSectionData, quickPicks: quickPicks);
  }

  Stream<Video> getSongIdFromPlayList(String playlistID) async* {
    Stream<Video> songStream = _youtubeExplode.playlists.getVideos(playlistID);
    yield* songStream;
  }

  // Future<List<yt.SongFull>> getPlayListSongs(
  //   List<String> songIds,
  // ) async {
  //   final List<yt.SongFull> songs = [];
  //   for (var i = 0; i < songIds.length; i++) {
  //     final data = await _ytMusic.getSong(songIds[i]);
  //     if (data.type == "SONG") {
  //       songs.add(data);
  //     }
  //   }

  //   return songs;
  // }

  //Testing
  Future<List<yt.SongFull>> getPlayListSongs(List<String> songIds) async {
    final results =
        await Future.wait(songIds.map((id) => _ytMusic.getSong(id)));
    return results;
    // .where((data) => data.type == "SONG")
    // .cast<yt.SongFull>()
    // .toList();
  }

  //Testing

  // Future<StreamManifest> songStreamUrl(String songId) async {
  //   return await _youtubeExplode.videos.streamsClient.getManifest(songId);
  // }

  Future<StreamManifest> songStreamUrl(String songId) {
    return _youtubeExplode.videos.streamsClient.getManifest(songId);
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
}
