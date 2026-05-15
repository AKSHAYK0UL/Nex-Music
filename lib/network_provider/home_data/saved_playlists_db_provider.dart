import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class SavedPlaylistsDBProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  SavedPlaylistsDBProvider({
    required String userId,
    required FirebaseFirestore firestoreInstance,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _savedPlaylistsCollection;

  void _initialize(String userid) {
    _userId = userid;
    _savedPlaylistsCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(savedPlaylistsCollection);
  }

  // Add playlist/album to saved playlists
  Future<void> addToSavedPlaylists(Map<String, dynamic> playlistMap) async {
    try {
      playlistMap["timestamp"] = FieldValue.serverTimestamp();
      await _savedPlaylistsCollection.add(playlistMap);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Get saved playlists (both playlists and albums)
  Stream<QuerySnapshot> getSavedPlaylists() {
    return _savedPlaylistsCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Check if playlist/album is saved
  Future<bool> isPlaylistSaved(String playlistId) async {
    try {
      final querySnapshot = await _savedPlaylistsCollection
          .where('playlist_id', isEqualTo: playlistId)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Remove playlist/album from saved playlists
  Future<void> removeFromSavedPlaylists(String playlistId) async {
    try {
      final querySnapshot = await _savedPlaylistsCollection
          .where('playlist_id', isEqualTo: playlistId)
          .get();
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
