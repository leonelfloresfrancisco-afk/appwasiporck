import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/google_auth_service.dart';

class GoogleAuthController {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    final UserCredential? credential = await _googleAuthService
        .signInWithGoogle();

    final User? user = credential?.user;

    if (user == null) return credential;

    await _ensureUserAndFarm(user);

    return credential;
  }

  Future<void> _ensureUserAndFarm(User user) async {
    final DocumentReference<Map<String, dynamic>> userRef = _firestore
        .collection('users')
        .doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

    if (userDoc.exists) return;

    final String farmId = _firestore.collection('farms').doc().id;

    final DocumentReference<Map<String, dynamic>> farmRef = _firestore
        .collection('farms')
        .doc(farmId);

    final WriteBatch batch = _firestore.batch();

    batch.set(userRef, {
      'uid': user.uid,
      'nombres': _extractFirstName(user.displayName),
      'apellidos': _extractLastName(user.displayName),
      'email': user.email ?? '',
      'telefono': user.phoneNumber ?? '',
      'photoUrl': user.photoURL ?? '',
      'farmId': farmId,
      'role': 'owner',
      'provider': 'google',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(farmRef, {
      'farmId': farmId,
      'ownerUid': user.uid,
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
  }

  String _extractFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Usuario';

    final parts = fullName.trim().split(RegExp(r'\s+'));

    return parts.first;
  }

  String _extractLastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';

    final parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.length <= 1) return '';

    return parts.skip(1).join(' ');
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
  }
}
