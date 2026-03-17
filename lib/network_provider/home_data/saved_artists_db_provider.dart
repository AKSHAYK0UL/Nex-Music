import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class SavedArtistsDBProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  SavedArtistsDBProvider({
    required String userId,
    required FirebaseFirestore firestoreInstance,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _savedArtistsCollection;

  void _initialize(String userid) {
    _userId = userid;
    _savedArtistsCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(savedArtistsCollection);
  }

  // Add artist to saved artists
  Future<void> addToSavedArtists(Map<String, dynamic> artistMap) async {
    try {
      artistMap["timestamp"] = FieldValue.serverTimestamp();
      await _savedArtistsCollection.add(artistMap);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Get saved artists
  Stream<QuerySnapshot> getSavedArtists() {
    return _savedArtistsCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Check if artist is saved
  Future<bool> isArtistSaved(String artistId) async {
    try {
      final querySnapshot =
          await _savedArtistsCollection.where('artist_id', isEqualTo: artistId).get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Remove artist from saved artists
  Future<void> removeFromSavedArtists(String artistId) async {
    try {
      final querySnapshot =
          await _savedArtistsCollection.where('artist_id', isEqualTo: artistId).get();
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

