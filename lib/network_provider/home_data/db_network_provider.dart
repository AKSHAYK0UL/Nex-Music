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
