import 'package:dart_ytmusic_api/types.dart' as yt;
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:nex_music/secrets/gcp_key.dart';
import 'package:nex_music/service/playlist_songs_getter.dart';
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
    // _ytMusic.dio.close();//remove in new version 1.3.6
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

  // Stream<Video> getSongIdFromPlayList(String playlistID) async* {
  //   String id = playlistID;
    
  //   // Handle full URLs if passed accidentally
  //   if (id.contains('list=')) {
  //     id = id.split('list=')[1].split('&')[0];
  //   }

  //   try {
  //     // Try fetching with the original ID first
  //     yield* _youtubeExplode.playlists.getVideos(id);
  //   } catch (e) {
  //     // For YT Music specific IDs (like Mixes starting with RD or Artist IDs UC)
  //     // YoutubeExplode often requires the 'VL' prefix to treat them as playlists.
  //     if (!id.startsWith('VL') && (id.startsWith('RD') || id.startsWith('UC') || id.startsWith('PL') == false)) {
  //       try {
  //         yield* _youtubeExplode.playlists.getVideos('VL$id');
  //       } catch (_) {
  //         // If both fail, rethrow the original error
  //         rethrow;
  //       }
  //     } else {
  //       rethrow;
  //     }
  //   }
  // }
 Future<List<VideoMetadata>> getSongIdFromPlayList(String playlistID) async {

 return await fetchPlaylistVideoMetadata(
  playlistId: playlistID,
  apiKey: ytApIKey,
);


 }

  //TESTING


  
  Future<List<yt.SongFull>> getPlayListSongs(List<String> songIds) async {
    final results =
        await Future.wait(songIds.map((id) => _ytMusic.getSong(id)));
    return results;
   
  }

 
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

  //get up next songs for radio feature
  Future<List<UpNextsDetails>> getUpNexts(String videoId) async {
    return await _ytMusic.getUpNexts(videoId);
  }
}


//TODO:
// _ytMusic.getAlbum(albumId)
// _ytMusic.getArtist(artistId)
// _ytMusic.getArtistSingles(artistId)
// _ytMusic.getPlaylist(playlistId)
// _ytMusic.getTimedLyrics(videoId)