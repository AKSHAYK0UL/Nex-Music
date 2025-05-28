import 'package:firebase_auth/firebase_auth.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';
import 'package:nex_music/network_provider/home_data/favorites_db_provider.dart';

class DbRepository {
  final DbNetworkProvider _dbDataProvider;
  final FavoritesDBProvider _favoritesDBProvider;
  DbRepository(
      {required DbNetworkProvider dbDataProvider,
      required FavoritesDBProvider favoritesDBProvider})
      : _dbDataProvider = dbDataProvider,
        _favoritesDBProvider = favoritesDBProvider;

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

  //Favorites

  //add
  Future<void> addToFavorites(Songmodel song) async {
    try {
      await _favoritesDBProvider.addToFavorites(song.toJson());
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //exists
  Future<bool> getIsFavorites(String vId) async {
    try {
      return await _favoritesDBProvider.getIsFavorites(vId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //remove
  Future<void> removeFromFavorites(String vId) async {
    try {
      return await _favoritesDBProvider.deleteFromFavorites(vId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get favorites
  Stream<List<Songmodel>> getFavorites() {
    final favSongsStream = _favoritesDBProvider.getFavorites();
    print("APLLE $favSongsStream");
    return favSongsStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Songmodel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
