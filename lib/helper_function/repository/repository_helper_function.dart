import 'package:dart_ytmusic_api/types.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';

class RepositoryHelperFunction {
  // Get QuickPicks
  static Future<List<Songmodel>> getQuickPicks(
      List<SongDetailed> quickPicks) async {
    List<Songmodel> songsList = [];
    for (var i = 0; i < quickPicks.length; i++) {
      final quickPicksDataObj = quickPicks[i];
      songsList.add(
        Songmodel(
          vId: quickPicksDataObj.videoId,
          songName: quickPicksDataObj.name,
          artist: quickPicksDataObj.artist,
          thumbnail: quickPicksDataObj.thumbnails.first.url,
        ),
      );
    }
    return songsList;
  }

  //Get PlayList
  static List<PlayListmodel> getPlaylists(List<HomeSection> homeSection) {
    List<PlayListmodel> playlists = [];

    for (int i = 0; i < homeSection.length; i++) {
      HomeSection section = homeSection[i];

      if (section.contents.isNotEmpty) {
        for (int j = 0; j < section.contents.length; j++) {
          var content = section.contents[j];
          if (content is PlaylistDetailed) {
            playlists.add(
              PlayListmodel(
                playListId: content.playlistId,
                playlistName: content.name,
                artistBasic: content.artist,
                thumbnail: content.thumbnails.first.url,
              ),
            );
          }
        }
      }
    }
    return playlists;
  }

//get songs
  static Future<List<Songmodel>> getSongsList(List<SongFull> songList) async {
    List<Songmodel> loadedSongsList = [];

    for (int i = 0; i < songList.length; i++) {
      final qpData = songList[i];

      loadedSongsList.add(
        Songmodel(
          vId: qpData.videoId,
          songName: qpData.name,
          artist: qpData.artist,
          thumbnail: qpData.thumbnails.first.url,
        ),
      );
    }

    return loadedSongsList;
  }
}
