import 'dart:isolate';

import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

class IsolateServiceClass {
  static Future<List<Songmodel>> getPlayListDataIsolate(
      Repository repository, String playlistId) async {
    return await Isolate.run(() {
      return repository.getPlayList(playlistId);
    });
  }
}
