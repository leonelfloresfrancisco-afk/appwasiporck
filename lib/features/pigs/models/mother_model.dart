import 'package:cloud_firestore/cloud_firestore.dart';

class MotherModel {
  final String motherId;
  final String farmId;
  final String code;
  final String breed;
  final String reproductiveStatus;
  final String status;
  final int historicalParturitions;
  final int totalBornAlive;
  final int totalWeaned;
  final double lifetimeMortalityRate;
  final Timestamp createdAt;

  const MotherModel({
    required this.motherId,
    required this.farmId,
    required this.code,
    required this.breed,
    required this.reproductiveStatus,
    required this.status,
    required this.historicalParturitions,
    required this.totalBornAlive,
    required this.totalWeaned,
    required this.lifetimeMortalityRate,
    required this.createdAt,
  });

  factory MotherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MotherModel(
      motherId: doc.id,
      farmId: data['farmId'] ?? '',
      code: data['code'] ?? '',
      breed: data['breed'] ?? '',
      reproductiveStatus: data['reproductiveStatus'] ?? 'empty',
      status: data['status'] ?? 'active',
      historicalParturitions: data['historicalParturitions'] ?? 0,
      totalBornAlive: data['totalBornAlive'] ?? 0,
      totalWeaned: data['totalWeaned'] ?? 0,
      lifetimeMortalityRate: (data['lifetimeMortalityRate'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
