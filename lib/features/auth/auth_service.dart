import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_config.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );
    _googleInitialized = true;
  }

  /// Connexion avec Google (google_sign_in 7.x) puis avec Firebase.
  /// Ne fait rien si l'utilisateur annule.
  Future<void> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google n\'a pas renvoyé de idToken.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureGoogleInitialized();
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
