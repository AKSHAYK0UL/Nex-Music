import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class SearchHistoryDBProvider {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;

  SearchHistoryDBProvider({
    required String userId,
    required FirebaseFirestore firestoreInstance,
  }) : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }

  late CollectionReference _searchHistoryCollection;

  void _initialize(String userId) {
    _userId = userId;
    _searchHistoryCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(searchHistoryCollection);
  }

  // Add search query to history
  Future<void> addSearchQuery(String query) async {
    try {
      // Check if query already exists
      final querySnapshot = await _searchHistoryCollection
          .where('query', isEqualTo: query)
          .get();

      // Delete existing entries to move to top
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Add new entry at the top
      await _searchHistoryCollection.add({
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Limit to last 50 searches - delete oldest if more than 50
      final allSearches = await _searchHistoryCollection
          .orderBy('timestamp', descending: false)
          .get();

      if (allSearches.docs.length > 50) {
        final toDelete = allSearches.docs.length - 50;
        for (int i = 0; i < toDelete; i++) {
          await allSearches.docs[i].reference.delete();
        }
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Get search history
  Stream<QuerySnapshot> getSearchHistory() {
    return _searchHistoryCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Delete a specific search query
  Future<void> deleteSearchQuery(String query) async {
    try {
      final querySnapshot = await _searchHistoryCollection
          .where('query', isEqualTo: query)
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

  // Clear all search history
  Future<void> clearAll() async {
    try {
      final allSearches = await _searchHistoryCollection.get();
      for (var doc in allSearches.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}

