import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/enum/collection_enum.dart';

class DbNetworkProvider {
  final FirebaseFirestore _firestoreInstance;
  late final Map<CollectionEnum, String> _collections;
  late final String _userId;
  late final CollectionReference _recentPlayedCollection;

  DbNetworkProvider({
    required FirebaseFirestore firestoreInstance,
    required String userId,
    required Map<CollectionEnum, String> collections,
  }) : _firestoreInstance = firestoreInstance {
    _userId = userId;
    _collections = collections;
    _recentPlayedCollection = _firestoreInstance
        .collection("Users")
        .doc(_userId)
        .collection(_collections[CollectionEnum.recentPlayed]!);
  }

  // Add to recent played collection
  Future<void> addToRecentPlayedCollection(Map<String, dynamic> songMap) async {
    await _recentPlayedCollection.add(songMap);
  }

  // TODO: Add methods for Get and Delete
}
