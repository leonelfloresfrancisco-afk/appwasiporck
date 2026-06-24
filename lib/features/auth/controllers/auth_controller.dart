import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService _authService = FirebaseAuthService();

  User? get currentUser => _authService.currentUser;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(email: email, password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _authService.register(email: email, password: password);
  }

  Future<void> recoverPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  bool isLoggedIn() {
    return _authService.isLoggedIn();
  }
}
