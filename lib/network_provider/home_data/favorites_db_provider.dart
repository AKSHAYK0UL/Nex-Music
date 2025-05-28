import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class FavoritesDBProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  FavoritesDBProvider(
      {required String userId, required FirebaseFirestore firestoreInstance})
      : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _favoritesCollection;

  void _initialize(String userid) {
    _userId = userid;
    _favoritesCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(favoritesCollection);
  }

  //add
  //on add
//store the song data in fav col just like recent
//when playing the song from the search just search the curr song id with the fav db songs id
  Future<void> addToFavorites(Map<String, dynamic> songMap) async {
    try {
      await _favoritesCollection.add(songMap);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get
  Stream<QuerySnapshot> getFavorites() {
    return _favoritesCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

//Exists
  Future<bool> getIsFavorites(String vId) async {
    try {
      final querySnapshot =
          await _favoritesCollection.where('v_id', isEqualTo: vId).get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //delete
  Future<void> deleteFromFavorites(String vId) async {
    try {
      final querySnapshot =
          await _favoritesCollection.where('v_id', isEqualTo: vId).get();
      for (var docs in querySnapshot.docs) {
        await docs.reference.delete();
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
