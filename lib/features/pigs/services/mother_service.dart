import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/farm_user_service.dart';
import '../models/mother_model.dart';

class MotherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FarmUserService _farmUserService = FarmUserService();

  Future<String?> getFarmId() async {
    return await _farmUserService.getCurrentFarmId();
  }

  Stream<List<MotherModel>> watchMothers(String farmId) {
    return _firestore
        .collection('farms')
        .doc(farmId)
        .collection('mothers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MotherModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> createMother({
    required String code,
    required String breed,
  }) async {
    final farmId = await _farmUserService.getCurrentFarmId();

    if (farmId == null || farmId.isEmpty) {
      throw Exception('No se encontró la granja del usuario');
    }

    final motherRef = _firestore
        .collection('farms')
        .doc(farmId)
        .collection('mothers')
        .doc();

    await motherRef.set({
      'motherId': motherRef.id,
      'farmId': farmId,
      'code': code.trim(),
      'breed': breed.trim(),
      'reproductiveStatus': 'empty',
      'status': 'active',
      'historicalParturitions': 0,
      'totalBornAlive': 0,
      'totalWeaned': 0,
      'lifetimeMortalityRate': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
