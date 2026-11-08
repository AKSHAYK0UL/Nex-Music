import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/model/songmodel.dart';

// Playlist_cache_CDN or Album_cache_CDN.
class CdnCacheModel {
  // YouTube playlist / album ID used as the Firestore document ID.
  final String id;
  final String name;
  final List<Songmodel> songs;

  // UTC timestamp when this entry was first created.
  final DateTime createdAt;

  // UTC timestamp of the last successful cache refresh.
  final DateTime updatedAt;

  const CdnCacheModel({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
  });

  //  Serialisation

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toJson()).toList(),
      'song_count': songs.length,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory CdnCacheModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value).toUtc();
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    final rawSongs = json['songs'] as List<dynamic>? ?? [];
    final songs = rawSongs
        .whereType<Map<String, dynamic>>()
        .map(Songmodel.fromJson)
        .toList();

    return CdnCacheModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      songs: songs,
      createdAt: parseTimestamp(json['created_at']),
      updatedAt: parseTimestamp(json['updated_at']),
    );
  }

  //   Helpers

  // Returns true when the cache entry is older than maxAge (default 48 h).
  bool isExpired({Duration maxAge = const Duration(hours: 48)}) {
    final age = DateTime.now().toUtc().difference(updatedAt.toUtc());
    return age >= maxAge;
  }

  // Creates an updated copy of this entry with a fresh song list and
  // a new updatedAt timestamp while keeping the original createdAt.
  CdnCacheModel copyWithSongs(List<Songmodel> newSongs) {
    return CdnCacheModel(
      id: id,
      name: name,
      songs: newSongs,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
