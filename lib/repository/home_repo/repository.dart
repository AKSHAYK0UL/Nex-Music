import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/helper_function/repository/repository_helper_function.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Repository {
  final YoutubeExplode _yt;
  final DataProvider _dataProvider;

  Repository({
    required DataProvider dataProvider,
    required YoutubeExplode yt,
  })  : _dataProvider = dataProvider,
        _yt = yt;

//using records
  Future<({List<Songmodel> quickPicks, List<PlayListmodel> playlist})>
      homeScreenSongsList() async {
    final networkData = await _dataProvider.homeScreenSongs;
    final quickPicks = RepositoryHelperFunction.getQuickPicks(
      networkData.quickPicks,
    );
    final playlist =
        RepositoryHelperFunction.getPlaylists(networkData.homeSectionData);

    return (quickPicks: quickPicks, playlist: playlist);
  }

  // Get playlist songs
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

  //Future<int> playListTotalSongs() async {}
  Future<Uri> getSongUrl(String songId) async {
    final manifest = await _dataProvider.songStreamUrl(songId);
    return manifest.audioOnly.withHighestBitrate().url;
  }

  Future<List<Songmodel>> searchSongs(String inputText) async {
    final songs = await _dataProvider.searchSong(inputText);
    final songsList = RepositoryHelperFunction.getQuickPicks(songs);
    return songsList;
  }
}
