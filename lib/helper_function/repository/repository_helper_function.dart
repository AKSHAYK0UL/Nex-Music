import 'package:dart_ytmusic_api/types.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
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
          // thumbnail: quickPicksDataObj.thumbnails[1].url,
          thumbnail: getThumbnail(quickPicksDataObj.thumbnails),
          duration: "",
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
  static Future<List<Songmodel>> getSongsList(
      List<SongFull> songList, List<int> songsDuration) async {
    List<Songmodel> loadedSongsList = [];

    for (int i = 0; i < songList.length; i++) {
      final playlistSongsData = songList[i];

      loadedSongsList.add(
        Songmodel(
          vId: playlistSongsData.videoId,
          songName: playlistSongsData.name,
          artist: playlistSongsData.artist,
          // thumbnail: playlistSongsData.thumbnails.first.url,
          thumbnail: getThumbnail(playlistSongsData.thumbnails),
          duration:
              songsDuration[i] == 0 ? "" : timeFormate(songsDuration[i] - 1),
        ),
      );
    }

    return loadedSongsList;
  }
}
