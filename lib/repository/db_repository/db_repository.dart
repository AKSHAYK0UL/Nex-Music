import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';

class DbRepository {
  final DbNetworkProvider _dbDataProvider;
  DbRepository(this._dbDataProvider);

  //Add recent Played
  Future<void> addToRecentPlayedCollection(Songmodel songData) async {
    await _dbDataProvider.addToRecentPlayedCollection(songData.toJson());
  }
}
