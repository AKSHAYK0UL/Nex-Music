import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class LyricsSyncDBProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  LyricsSyncDBProvider({
    required String userId,
    required FirebaseFirestore firestoreInstance,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _lyricsSyncCollection;

  void _initialize(String userId) {
    _userId = userId;
    _lyricsSyncCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(lyricsSyncOffsetsCollection);
  }

  Future<void> saveSyncOffset(
    String videoId,
    String sourceName,
    int offsetMs,
  ) async {
    try {
      await _lyricsSyncCollection.doc(videoId).set(
        {sourceName: offsetMs},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSyncOffsets(String videoId) async {
    try {
      final doc = await _lyricsSyncCollection.doc(videoId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
