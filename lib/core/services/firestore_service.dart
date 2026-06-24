import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarUsuario({
    required String uid,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
  }) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'rol': 'usuario',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }
}
