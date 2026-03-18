import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class DbNetworkProvider {
  final FirebaseFirestore _firestoreInstance;
  // late Map<CollectionEnum, String> _collections;
  late String _userId;

  DbNetworkProvider({
    required FirebaseFirestore firestoreInstance,
    required String userId,
    // required Map<CollectionEnum, String> collections,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _recentPlayedCollection;
  void _initialize(String userId) {
    _userId = userId;
    // _collections = collections;
    _recentPlayedCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(recentsCollection);
    // .collection(_collections[CollectionEnum.recentPlayed]!);
  }

  Future<void> addToRecentPlayedCollection(Map<String, dynamic> songMap) async {
    // Clean up old documents with auto-generated IDs (from legacy .add() calls)
    final oldDocs = await _recentPlayedCollection
        .where("v_id", isEqualTo: songMap["v_id"])
        .get();
    for (var doc in oldDocs.docs) {
      // Only delete docs with random IDs (not the one we're about to set)
      if (doc.id != songMap["v_id"]) {
        doc.reference.delete();
      }
    }
    songMap["timestamp"] = FieldValue.serverTimestamp();
    await _recentPlayedCollection.doc(songMap["v_id"]).set(songMap);
  }

  Stream<QuerySnapshot> getRecentPlayed() {
    return _recentPlayedCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteRecentPlayedSong(String vId) async {
    await _recentPlayedCollection.doc(vId).delete();
  }
}
