import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> register({
    required String nombres,
    required String apellidos,
    required String email,
    required String password,
    String telefono = '',
  }) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

    await _firestore.collection('usuarios').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'fechaRegistro': Timestamp.now(),
    });

    return credential;
  }
}
