import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nex_music/constants/const.dart';
import 'package:nex_music/model/cdn_cache_model.dart';
import 'package:nex_music/model/songmodel.dart';

// Firestore access for the two global CDN cache collections.
// Both collections are at the **root** of Firestore (not under any user
// document) so that every user can read  from the same cached data.

class CdnCacheDbProvider {
  final FirebaseFirestore _firestore;

  CdnCacheDbProvider({required FirebaseFirestore firestoreInstance})
      : _firestore = firestoreInstance;

  // Internal helpers

  CollectionReference get _playlistCollection =>
      _firestore.collection(cdnPlaylistCacheCollection);

  CollectionReference get _albumCollection =>
      _firestore.collection(cdnAlbumCacheCollection);

  CollectionReference _collectionFor(bool isAlbum) =>
      isAlbum ? _albumCollection : _playlistCollection;

  //  Read

  // Fetches a single cache entry by id.
  // Returns null when the document does not exist or on any error.
  Future<CdnCacheModel?> getCacheEntry(
    String id, {
    required bool isAlbum,
  }) async {
    try {
      final doc = await _collectionFor(isAlbum).doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;
      return CdnCacheModel.fromJson(data);
    } on FirebaseException catch (e) {
      debugPrint('[CdnCacheDbProvider] getCacheEntry error: $e');
      return null;
    } catch (e) {
      debugPrint('[CdnCacheDbProvider] getCacheEntry unexpected error: $e');
      return null;
    }
  }

  //  Write

  // Saves a new cache entry.  The document ID is model.id
  Future<void> saveEntry(
    CdnCacheModel model, {
    required bool isAlbum,
  }) async {
    try {
      await _collectionFor(isAlbum).doc(model.id).set(model.toJson());
    } on FirebaseException catch (e) {
      debugPrint('[CdnCacheDbProvider] saveEntry error: $e');
    } catch (e) {
      debugPrint('[CdnCacheDbProvider] saveEntry unexpected error: $e');
    }
  }

  // Updates only the song list, song count, and updated_at on an existing
  // document.  Uses SetOptions(merge: true) so unrelated fields are kept.
  Future<void> updateSongs(
    String id,
    List<Songmodel> songs, {
    required bool isAlbum,
  }) async {
    try {
      await _collectionFor(isAlbum).doc(id).set(
        {
          'songs': songs.map((s) => s.toJson()).toList(),
          'song_count': songs.length,
          'updated_at': Timestamp.fromDate(DateTime.now().toUtc()),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      debugPrint('[CdnCacheDbProvider] updateSongs error: $e');
    } catch (e) {
      debugPrint('[CdnCacheDbProvider] updateSongs unexpected error: $e');
    }
  }

  // Checks whether a document with id already exists.
  Future<bool> entryExists(String id, {required bool isAlbum}) async {
    try {
      final doc = await _collectionFor(isAlbum).doc(id).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
