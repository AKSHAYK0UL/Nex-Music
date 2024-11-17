import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/helper_function/repository/repository_helper_function.dart';
import 'package:nex_music/model/artistmodel.dart';
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

  //Future<int> playListTotalSongs() async {}
  Future<Uri> getSongUrl(String songId) async {
    final manifest = await _dataProvider.songStreamUrl(songId);
    return manifest.audioOnly.withHighestBitrate().url;
  }

  //Search suggestion
  Future<List<String>> searchSuggetion(String query) async {
    return await _dataProvider.searchSuggestion(query);
  }

//seach in songs
  Future<List<Songmodel>> searchSong(String inputText) async {
    final searchResults = await _dataProvider.searchSong(inputText);
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
}
