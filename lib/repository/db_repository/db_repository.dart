import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';

class DbRepository {
  final DbNetworkProvider _dbDataProvider;
  DbRepository(this._dbDataProvider);

  //Add recent Played
  Future<void> addToRecentPlayedCollection(Songmodel songData) async {
    await _dbDataProvider.addToRecentPlayedCollection(songData.toJson());
  }

  //Get recent Played
  Stream<List<Songmodel>> getRecentPlayed() {
    final recentPlayedStream = _dbDataProvider.getRecentPlayed();
    return recentPlayedStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Songmodel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> deleteRecentPlayedSong(String vId) async {
    await _dbDataProvider.deleteRecentPlayedSong(vId);
  }
}
