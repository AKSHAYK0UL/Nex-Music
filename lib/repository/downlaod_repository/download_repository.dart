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
}
