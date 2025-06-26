import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nex_music/constants/const.dart';

class ThinkProvide {
  final FirebaseFirestore _firestoreInstance;
  late String _userId;
  ThinkProvide(
      {required String userId, required FirebaseFirestore firestoreInstance})
      : _firestoreInstance = firestoreInstance {
    _initialize(userId);
  }
  late CollectionReference _thinkCollection;

  void _initialize(String userid) {
    _userId = userid;
    _thinkCollection = _firestoreInstance
        .collection(userCollection)
        .doc(_userId)
        .collection(thinkUserData);
  }

  Future<void> saveThinkRecommendationData(String data) async {
    try {
      await _thinkCollection.doc(thinkUserData).set({'data': data});
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<String> get getThinkRecommendationData async {
    try {
      final doc = await _thinkCollection.doc(thinkUserData).get();
      if (doc.exists) {
        return doc['data'] as String;
      } else {
        return 'No recommendation found';
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
