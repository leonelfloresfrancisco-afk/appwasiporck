import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/google_auth_service.dart';

class GoogleAuthController {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  Future<UserCredential?> signInWithGoogle() async {
    return await _googleAuthService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
  }
}
