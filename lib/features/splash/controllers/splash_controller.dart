import 'package:firebase_auth/firebase_auth.dart';

class SplashController {
  Future<bool> verificarSesion() async {
    await Future.delayed(const Duration(seconds: 4));

    final User? user = FirebaseAuth.instance.currentUser;

    return user != null;
  }
}
