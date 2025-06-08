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

  //create new collect for new playlist -> collection(playlist)->collection(new playlist)->songs
  Future<void> createUserPlaylistCollection(String playlistName) async {
    final docRef = _playlistCollection.doc(playlistName);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': playlistName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  //fetch playlists
  Stream<QuerySnapshot> getUserPlaylists() {
    return _playlistCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //add
  Future<void> addSongToPlaylist(
      String playlistName, Map<String, dynamic> songData) async {
    try {
      await _playlistCollection
          .doc(playlistName)
          .collection(userPlaylistSongs)
          .add(songData);
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
}
