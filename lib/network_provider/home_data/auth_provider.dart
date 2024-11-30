import 'package:firebase_auth/firebase_auth.dart';

class AuthProviderr {
  final FirebaseAuth _firebaseAuth;

  AuthProviderr(this._firebaseAuth);

  Future<void> googleSignIn(OAuthCredential credential) async {
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
