import 'dart:io';

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nex_music/network_provider/home_data/auth_provider.dart';
import 'package:nex_music/secrets/gcp_key.dart';

class AuthRepository {
  final AuthProviderr _authProvider;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._authProvider, this._googleSignIn);

//For android
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

//For windows
  Future<void> googleDesktopSignIn() async {
    final result = await DesktopWebviewAuth.signIn(
      GoogleSignInArgs(
        clientId: CLIENT_ID,
        redirectUri: REDIRECT_URI,
        scope: 'openid email profile',
      ),
    );

    if (result != null) {
      final credential = GoogleAuthProvider.credential(
        idToken: result.idToken,
        accessToken: result.accessToken,
      );
      await _authProvider.googleSignIn(credential);
    }
  }

  Future<void> signOut() async {
    if (!Platform.isWindows) {
      await _googleSignIn.disconnect();
    }
    await _authProvider.signOut();
  }
}
