import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/enum/collection_enum.dart';

class DbNetworkProvider {
  final FirebaseFirestore _firestoreInstance;
  late final Map<CollectionEnum, String> _collections;
  late final String _userId;
  late final CollectionReference _recentPlayedCollection;
  final String _usersCollection = "users";

  DbNetworkProvider({
    required FirebaseFirestore firestoreInstance,
    required String userId,
    required Map<CollectionEnum, String> collections,
  }) : _firestoreInstance = firestoreInstance {
    _userId = userId;
    _collections = collections;
    _recentPlayedCollection = _firestoreInstance
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_collections[CollectionEnum.recentPlayed]!);
  }

  // Add to recent played collection
  Future<void> addToRecentPlayedCollection(Map<String, dynamic> songMap) async {
    // Query for an existing instance of the song
    final querySnapShot = await _recentPlayedCollection
        .where("v_id", isEqualTo: songMap["v_id"])
        .get();
    for (var songs in querySnapShot.docs) {
      await songs.reference.delete();
    }
    //add the timestamp of when the song was played
    songMap["timestamp"] = FieldValue.serverTimestamp();

    //add to recent collection
    await _recentPlayedCollection.add(songMap);
  }

  // Get Recent Played
  Stream<QuerySnapshot> getRecentPlayed() {
    return _recentPlayedCollection
        .orderBy('timestamp', descending: true) //sort by timestamp
        .snapshots();
  }

  //delete recent Played song
  Future<void> deleteRecentPlayedSong(String vId) async {
    final querySnapshot =
        await _recentPlayedCollection.where('v_id', isEqualTo: vId).get();
    for (var docs in querySnapshot.docs) {
      await docs.reference.delete();
    }
  }
}
