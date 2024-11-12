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

  //get home section data
  Future<({List<HomeSection> homeSectionData, List<SongDetailed> quickPicks})>
      get homeScreenSongs async {
    await _ytMusic.initialize();
    final fetchedData = await Future.wait(
      [
        _ytMusic.getHomeSections(),
        _ytMusic.searchSongs("Trending Punjabi Songs of this month"),
      ],
    );

    final homeSectionData =
        fetchedData[0] as List<HomeSection>; //PlayList, Album
    final quickPicks = fetchedData[1] as List<SongDetailed>; ////Quick Picks

    return (homeSectionData: homeSectionData, quickPicks: quickPicks);
  }

  Stream<Video> getSongIdFromPlayList(String playlistID) async* {
    Stream<Video> songStream = _youtubeExplode.playlists.getVideos(playlistID);
    yield* songStream;
  }

  Future<List<SongFull>> getPlayListSongs(
    List<String> songIds,
  ) async {
    final List<SongFull> songs = [];
    for (var i = 0; i < songIds.length; i++) {
      final data = await _ytMusic.getSong(songIds[i]);
      if (data.type == "SONG") {
        songs.add(data);
      }
    }

    return songs;
  }

  Future<StreamManifest> songStreamUrl(String songId) async {
    return await _youtubeExplode.videos.streamsClient.getManifest(songId);
  }

  //search
  Future<List<SongDetailed>> searchSong(String inputText) async {
    return await _ytMusic.searchSongs(inputText);

    // final a = _ytMusic.searchAlbums(inputText);
    // final art = _ytMusic.searchArtists(inputText);
  }
}
