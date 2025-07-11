import 'package:nex_music/helper_function/delete_offline_songs/delete_offlice_songs.dart';
import 'package:nex_music/helper_function/load_offline_songs/loadsong.dart';
import 'package:nex_music/model/song_raw_data.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/download_provider.dart';

class DownloadRepo {
  final DownloadProvider _downloadProvider;

  DownloadRepo(this._downloadProvider);

  Stream<double> downloadSong(SongRawData songRawInfo, Songmodel songData) {
    try {
      final actualDownformat =
          songRawInfo.codecs.contains("mp") ? "m4a" : "opus";
      print("ACTUAL DOWNLOAD FORMATE $actualDownformat @@@@");
      return _downloadProvider.downloadSong(
        songRawInfo,
        actualDownformat,
        songData.toJson(),
      );
    } catch (_) {
      rethrow;
    }
  }

  Stream<List<Songmodel>> get loadOfflineSongs {
    return loadDownloadedSongsStream(); //helper function
  }

  //delete saved songs
  Future<void> deleteDownLoadedSong(Songmodel songData) async {
    try {
      await deleteDownloadedSong(songData);
    } catch (_) {
      rethrow;
    }
  }
}
