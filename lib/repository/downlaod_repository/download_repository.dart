import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/download_provider.dart';

class DownloadRepo {
  final DownloadProvider _downloadProvider;

  DownloadRepo(this._downloadProvider);

  Stream<double> downloadSong(String url, Songmodel songData) {
    try {
      return _downloadProvider.downloadSong(
        url,
        songData.toJson(),
      );
    } catch (_) {
      rethrow;
    }
  }
}
