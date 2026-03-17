import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class PlaylistDbProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  PlaylistDbProvider(
      {required String userId, required FirebaseFirestore firestoreInstance})
      : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _playlistCollection;

  void _initialize(String userid) {
    _userId = userid;
    _playlistCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(playlistCollection);
  }

  //create new collect for new playlist ->collection(playlist)->collection(new playlist)->songs
  Future<void> createUserPlaylistCollection(
    String playlistName, {
    String description = '',
    int colorValue = 0xFFE53935,
    String displayMode = 'color',
    bool isPublic = false,
  }) async {
    final docRef = _playlistCollection.doc(playlistName);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': playlistName,
        'description': description,
        'colorValue': colorValue,
        'displayMode': displayMode,
        'isPublic': isPublic,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  //fetch playlists - now returns full metadata
  Stream<QuerySnapshot> getUserPlaylists() {
    return _playlistCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //add
  Future<void> addSongToPlaylist(
      String playlistName, Map<String, dynamic> songMap) async {
    try {
      final querySnapshot = await _playlistCollection
          .doc(playlistName)
          .collection(userPlaylistSongs)
          .where('v_id', isEqualTo: songMap['v_id'])
          .get();
      songMap["timestamp"] = FieldValue.serverTimestamp();

      if (querySnapshot.docs.isEmpty) {
        await _playlistCollection
            .doc(playlistName)
            .collection(userPlaylistSongs)
            .add(songMap);
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get Playlist songs
  Stream<QuerySnapshot> getUserPlaylistSongs(String playlistName) {
    return _playlistCollection
        .doc(playlistName)
        .collection(userPlaylistSongs)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //delete playlist
  Future<void> deleteUserPlaylist(String playlistName) async {
    try {
      // Check if it was public before deleting
      final doc = await _playlistCollection.doc(playlistName).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['isPublic'] == true) {
          // Also delete from public collection
          await deletePublicPlaylist(playlistName);
        }
      }
      await _playlistCollection.doc(playlistName).delete();
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //delete song from the playlist
  Future<void> deleteSongUserPlaylist(String playlistName, vId) async {
    try {
      final querySnapshot = await _playlistCollection
          .doc(playlistName)
          .collection(userPlaylistSongs)
          .where('v_id', isEqualTo: vId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //PUBLIC PLAYLISTS

  // Create/update a public playlist document accessible by other users
  Future<void> createPublicPlaylist(
    String playlistName, {
    String description = '',
    int colorValue = 0xFFE53935,
    String displayMode = 'color',
  }) async {
    try {
      final publicCollection =
          _firestoreInstance.collection(publicPlaylistsCollection);

      // Use a composite ID to avoid collisions: userId_playlistName
      final publicDocId = '${_userId}_$playlistName';

      await publicCollection.doc(publicDocId).set({
        'name': playlistName,
        'description': description,
        'colorValue': colorValue,
        'displayMode': displayMode,
        'ownerId': _userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Delete a public playlist document
  Future<void> deletePublicPlaylist(String playlistName) async {
    try {
      final publicCollection =
          _firestoreInstance.collection(publicPlaylistsCollection);
      final publicDocId = '${_userId}_$playlistName';
      await publicCollection.doc(publicDocId).delete();
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
