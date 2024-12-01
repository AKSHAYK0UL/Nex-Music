import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nex_music/network_provider/home_data/auth_provider.dart';

class AuthRepository {
  final AuthProviderr _authProvider;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._authProvider, this._googleSignIn);

  Future<void> googleSignIn() async {
    final gUser = await _googleSignIn.signIn();
    if (gUser == null) return;
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    await _authProvider.googleSignIn(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _authProvider.signOut();
  }
}
