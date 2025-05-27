import 'package:dart_ytmusic_api/types.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/helper_function/general/thumbnail.dart';
import 'package:nex_music/helper_function/general/timeformate.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RepositoryHelperFunction {
  // Get QuickPicks
  static Future<List<Songmodel>> getQuickPicks(
      List<SongDetailed> quickPicks, ThumbnailQuality quality) async {
    List<Songmodel> songsList = [];
    for (var i = 0; i < quickPicks.length; i++) {
      final quickPicksDataObj = quickPicks[i];
      songsList.add(
        Songmodel(
          vId: quickPicksDataObj.videoId,
          songName: quickPicksDataObj.name,
          artist: quickPicksDataObj.artist,
          thumbnail: quality == ThumbnailQuality.low
              ? getThumbnail(quickPicksDataObj.thumbnails)
              : await getThumbnailUsingUrl(quickPicksDataObj.videoId),
          duration: timeFormate(quickPicksDataObj.duration ?? 0),
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
                thumbnail: getThumbnail(content.thumbnails),
              ),
            );
          }
        }
      }
    }
    return playlists;
  }

//get songs
  static List<Songmodel> getSongsList(
      List<SongFull> songList, List<int> songsDuration) {
    List<Songmodel> loadedSongsList = [];

    for (int i = 0; i < songList.length; i++) {
      final playlistSongsData = songList[i];

      loadedSongsList.add(
        Songmodel(
          vId: playlistSongsData.videoId,
          songName: playlistSongsData.name,
          artist: playlistSongsData.artist,
          thumbnail: getThumbnail(playlistSongsData.thumbnails),
          duration: songsDuration[i] == 0 ? "" : timeFormate(songsDuration[i]),
        ),
      );
    }

    return loadedSongsList;
  }

  //PlaylistDetailed to PlayListModel
  static List<PlayListmodel> getPlaylistDetailedToPlayListModel(
      List<PlaylistDetailed> detailedPlaylist) {
    List<PlayListmodel> playlists = [];

    for (int i = 0; i < detailedPlaylist.length; i++) {
      final playlist = detailedPlaylist[i];

      playlists.add(
        PlayListmodel(
          playListId: playlist.playlistId,
          playlistName: playlist.name,
          artistBasic: playlist.artist,
          thumbnail: getThumbnail(playlist.thumbnails),
        ),
      );
    }

    return playlists;
  }

  //artist
  static List<ArtistModel> getArtist(List<ArtistDetailed> artist) {
    final artists = artist
        .map(
          (art) => ArtistModel(
            artist: ArtistBasic(name: art.name, artistId: art.artistId),
            thumbnail: getThumbnail(art.thumbnails),
          ),
        )
        .toList();
    return artists;
  }

  //album to playlist
  static List<PlayListmodel> albumsToPlaylist(List<AlbumDetailed> album) {
    List<PlayListmodel> playlist = [];
    for (int i = 0; i < album.length; i++) {
      final data = album[i];
      playlist.add(
        PlayListmodel(
          playListId: data.playlistId,
          playlistName: data.name,
          artistBasic: data.artist,
          thumbnail: getThumbnail(data.thumbnails),
        ),
      );
    }
    return playlist;
  }

  //SongFull to SongModel
  static Songmodel convertSongFullToSongModel(SongFull songfull) {
    return Songmodel(
        vId: songfull.videoId,
        songName: songfull.name,
        artist: songfull.artist,
        thumbnail: getThumbnail(songfull.thumbnails),
        duration: songfull.duration == 0 ? "" : timeFormate(songfull.duration));
  }

  //VideoFull to SongModel
  static Songmodel convertVideoFullToSongModel(VideoFull videofull) {
    return Songmodel(
        vId: videofull.videoId,
        songName: videofull.name,
        artist: videofull.artist,
        thumbnail: getThumbnail(videofull.thumbnails),
        duration:
            videofull.duration == 0 ? "" : timeFormate(videofull.duration));
  }

  static AudioOnlyStreamInfo selectStream(
      List<AudioOnlyStreamInfo> streams, AudioQuality quality) {
    switch (quality) {
      case AudioQuality.high:
        // Prefer itag 251 or 140 for high quality.
        return streams.lastWhere(
          (stream) => stream.tag == 251 || stream.tag == 140,
          orElse: () => streams.first,
        );
      case AudioQuality.medium:
        // Choose itag 250 or 139 for medium quality.
        return streams.lastWhere(
          (stream) => stream.tag == 250 || stream.tag == 139,
          orElse: () => streams.first,
        );
      case AudioQuality.low:
        // Select itag 249 for low quality.
        return streams.lastWhere(
          (stream) => stream.tag == 249,
          orElse: () => streams.first,
        );
    }
  }
}
