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
    final quickPicks = await RepositoryHelperFunction.getQuickPicks(
      networkData.quickPicks,
    );
    final playlist =
        RepositoryHelperFunction.getPlaylists(networkData.homeSectionData);

    return (quickPicks: quickPicks, playlist: playlist);
  }

  // Get playlist songs
  Future<List<Songmodel>> getPlayList(
    String playlistId,
  ) async {
    final songStream = _dataProvider.getSongIdFromPlayList(playlistId);
    List<String> songIds =
        await songStream.map((video) => video.id.value).toList();

    final songsList = await _dataProvider.getPlayListSongs(songIds);

    return await RepositoryHelperFunction.getSongsList(songsList);
  }

  Future<Uri> getSongUrl(String songId) async {
    final manifest = await _dataProvider.songStreamUrl(songId);
    return manifest.audioOnly.withHighestBitrate().url;
  }
}
