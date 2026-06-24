import 'package:firebase_auth/firebase_auth.dart';

class SplashController {
  Future<bool> verificarSesion() async {
    await Future.delayed(const Duration(seconds: 6));

    final user = FirebaseAuth.instance.currentUser;

    return user != null;
  }
}
