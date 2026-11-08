import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nex_music/model/cdn_cache_model.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/cdn_cache_db_provider.dart';

// Return type for CdnCacheRepository.getPlaylistOrAlbum.

class CdnCacheRepository {
  final CdnCacheDbProvider _dbProvider;

  final Set<String> _inFlightWrites = {};

  CdnCacheRepository({required CdnCacheDbProvider dbProvider})
      : _dbProvider = dbProvider;

  //  Main entry point

  Future<CdnCacheModel?> getFromCache(
    String id, {
    required bool isAlbum,
  }) async {
    try {
      final entry = await _dbProvider.getCacheEntry(id, isAlbum: isAlbum);
      return entry;
    } catch (e) {
      debugPrint('[CdnCacheRepository] getFromCache error: $e');
      return null;
    }
  }

  //  Background sync

  // Compares the cached song list against the freshly fetched latestSongs
  // Rules:
  //    Same count AND same IDs in same order -> no-op.
  //    Any difference -> update CDN with latestSongs.
  Future<void> backgroundSync(
    String id, {
    required bool isAlbum,
    required List<Songmodel> cachedSongs,
    required Future<List<Songmodel>> Function() ytFetcher,
  }) async {
    try {
      final latestSongs = await ytFetcher();

      if (latestSongs.isEmpty) {
        // YouTube returned nothing keep the existing cache
        debugPrint(
            '[CdnCacheRepository] backgroundSync: YT returned empty list for $id, skipping update.');
        return;
      }

      final needsUpdate = _songsAreDifferent(cachedSongs, latestSongs);

      if (!needsUpdate) {
        debugPrint(
            '[CdnCacheRepository] backgroundSync: songs unchanged for $id, no update needed.');
        return;
      }

      debugPrint(
          '[CdnCacheRepository] backgroundSync: songs differ for $id (cached=${cachedSongs.length}, latest=${latestSongs.length}), updating cache.');
      await _dbProvider.updateSongs(id, latestSongs, isAlbum: isAlbum);
    } catch (e) {
      // Background failures must never surface to the user.
      debugPrint('[CdnCacheRepository] backgroundSync error (suppressed): $e');
    }
  }

  //  Cache write

  // Saves a new cache entry.  No-op if the entry already exists in Firestore
  // (to avoid redundant writes when several users open the same uncached
  // playlist simultaneously).
  // This is intentionally fire-and-forget callers should **not** await it
  // unless they explicitly need to know when it finishes.
  Future<void> saveToCache(
    String id,
    String name,
    List<Songmodel> songs, {
    required bool isAlbum,
  }) async {
    if (songs.isEmpty) return;
    if (_inFlightWrites.contains(id)) {
      debugPrint(
          '[CdnCacheRepository] saveToCache: write already in-flight for $id, skipping.');
      return;
    }
    _inFlightWrites.add(id);
    try {
      final alreadyExists = await _dbProvider.entryExists(id, isAlbum: isAlbum);
      if (alreadyExists) {
        debugPrint(
            '[CdnCacheRepository] saveToCache: entry already exists for $id, skipping insert.');
        return;
      }

      final now = DateTime.now().toUtc();
      final model = CdnCacheModel(
        id: id,
        name: name,
        songs: songs,
        createdAt: now,
        updatedAt: now,
      );
      await _dbProvider.saveEntry(model, isAlbum: isAlbum);
      debugPrint(
          '[CdnCacheRepository] saveToCache: saved ${songs.length} songs for $id.');
    } catch (e) {
      debugPrint('[CdnCacheRepository] saveToCache error (suppressed): $e');
    } finally {
      _inFlightWrites.remove(id);
    }
  }

  // Updates an existing expired cache entry with fresh songs
  Future<void> updateCache(
    String id,
    List<Songmodel> songs, {
    required bool isAlbum,
  }) async {
    if (songs.isEmpty) return;
    try {
      await _dbProvider.updateSongs(id, songs, isAlbum: isAlbum);
      debugPrint(
          '[CdnCacheRepository] updateCache: updated ${songs.length} songs for $id.');
    } catch (e) {
      debugPrint('[CdnCacheRepository] updateCache error (suppressed): $e');
    }
  }

  //  Utility

  // Returns true when fresh differs from cached by count or by any song ID.
  bool _songsAreDifferent(List<Songmodel> cached, List<Songmodel> fresh) {
    if (cached.length != fresh.length) return true;
    for (var i = 0; i < cached.length; i++) {
      if (cached[i].vId != fresh[i].vId) return true;
    }
    return false;
  }
}
