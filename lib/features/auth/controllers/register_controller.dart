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

    final User? user = credential.user;

    if (user == null) {
      throw Exception('No se pudo crear el usuario');
    }

    final String uid = user.uid;
    final String farmId = _firestore.collection('farms').doc().id;

    final WriteBatch batch = _firestore.batch();

    final DocumentReference<Map<String, dynamic>> userRef = _firestore
        .collection('users')
        .doc(uid);

    final DocumentReference<Map<String, dynamic>> farmRef = _firestore
        .collection('farms')
        .doc(farmId);

    batch.set(userRef, {
      'uid': uid,
      'nombres': nombres.trim(),
      'apellidos': apellidos.trim(),
      'email': email.trim(),
      'telefono': telefono.trim(),
      'farmId': farmId,
      'role': 'owner',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(farmRef, {
      'farmId': farmId,
      'ownerUid': uid,
      'name': 'Mi Granja',
      'location': '',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'settings': {
        'lactationDays': 21,
        'gestationDays': 114,
        'estrusStartDayAfterWeaning': 3,
        'estrusEndDayAfterWeaning': 7,
      },
    });

    await batch.commit();

    await user.updateDisplayName('${nombres.trim()} ${apellidos.trim()}');

    return credential;
  }
}
