import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/enum/collection_enum.dart';

class DbNetworkProvider {
  final FirebaseFirestore _firestoreInstance;
  late Map<CollectionEnum, String> _collections;
  late String _userId;
  late CollectionReference _recentPlayedCollection;
  final String _usersCollection = "users";

  DbNetworkProvider({
    required FirebaseFirestore firestoreInstance,
    required String userId,
    required Map<CollectionEnum, String> collections,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId, collections);
  }

  void _initialize(String userId, Map<CollectionEnum, String> collections) {
    _userId = userId;
    _collections = collections;
    _recentPlayedCollection = _firestoreInstance
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_collections[CollectionEnum.recentPlayed]!);
  }

  Future<void> addToRecentPlayedCollection(Map<String, dynamic> songMap) async {
    final querySnapShot = await _recentPlayedCollection
        .where("v_id", isEqualTo: songMap["v_id"])
        .get();
    for (var songs in querySnapShot.docs) {
      await songs.reference.delete();
    }
    songMap["timestamp"] = FieldValue.serverTimestamp();
    await _recentPlayedCollection.add(songMap);
  }

  Stream<QuerySnapshot> getRecentPlayed() {
    return _recentPlayedCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteRecentPlayedSong(String vId) async {
    final querySnapshot =
        await _recentPlayedCollection.where('v_id', isEqualTo: vId).get();
    for (var docs in querySnapshot.docs) {
      await docs.reference.delete();
    }
  }
}
