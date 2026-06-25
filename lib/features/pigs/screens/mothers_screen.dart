import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/mother_model.dart';

class MothersScreen extends StatelessWidget {
  const MothersScreen({super.key});

  Future<String?> _getFarmId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['farmId'];
  }

  Stream<List<MotherModel>> _mothersStream(String farmId) {
    return FirebaseFirestore.instance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRegisterMotherSheet(context);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva madre',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: _getFarmId(),
          builder: (context, farmSnapshot) {
            if (farmSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final farmId = farmSnapshot.data;

            if (farmId == null || farmId.isEmpty) {
              return const _EmptyState(
                title: 'Granja no encontrada',
                subtitle: 'No se encontró una granja asociada a tu usuario.',
              );
            }

            return StreamBuilder<List<MotherModel>>(
              stream: _mothersStream(farmId),
              builder: (context, snapshot) {
                final mothers = snapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 90),
                  children: [
                    _Header(total: mothers.length),
                    const SizedBox(height: 16),
                    _SummaryRow(mothers: mothers),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'Madres registradas'),
                    const SizedBox(height: 10),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (mothers.isEmpty)
                      const _EmptyState(
                        title: 'Aún no hay madres',
                        subtitle:
                            'Registra tu primera cerda reproductora para iniciar el control productivo.',
                      )
                    else
                      ...mothers.map((mother) => _MotherCard(mother: mother)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;

  const _Header({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Madres',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Control reproductivo por cerda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '$total total',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<MotherModel> mothers;

  const _SummaryRow({required this.mothers});

  @override
  Widget build(BuildContext context) {
    final active = mothers.where((m) => m.status == 'active').length;
    final pregnant = mothers
        .where((m) => m.reproductiveStatus == 'pregnant')
        .length;
    final lactating = mothers
        .where((m) => m.reproductiveStatus == 'lactating')
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.pets_rounded,
            value: '$active',
            label: 'Activas',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.biotech_rounded,
            value: '$pregnant',
            label: 'Gestantes',
            color: AppColors.dark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.child_care_rounded,
            value: '$lactating',
            label: 'Lactancia',
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotherCard extends StatelessWidget {
  final MotherModel mother;

  const _MotherCard({required this.mother});

  Color get statusColor {
    if (mother.status == 'culled') return AppColors.danger;
    if (mother.reproductiveStatus == 'pregnant') return AppColors.primary;
    if (mother.reproductiveStatus == 'lactating') return AppColors.dark;
    return Colors.grey;
  }

  String get statusText {
    if (mother.status == 'culled') return 'Descartada';
    if (mother.status == 'dead') return 'Muerta';
    if (mother.reproductiveStatus == 'pregnant') return 'Gestante';
    if (mother.reproductiveStatus == 'lactating') return 'Lactancia';
    return 'Vacía';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.pets_rounded, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arete ${mother.code}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mother.breed.isEmpty ? 'Raza no registrada' : mother.breed,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ChipLabel(text: statusText, color: statusColor),
                    const SizedBox(width: 6),
                    _ChipLabel(
                      text: '${mother.historicalParturitions} partos',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _ChipLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets_rounded, color: AppColors.primary, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showRegisterMotherSheet(BuildContext context) async {
  final codeController = TextEditingController();
  final breedController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        child: _RegisterMotherForm(
          codeController: codeController,
          breedController: breedController,
        ),
      );
    },
  );

  codeController.dispose();
  breedController.dispose();
}

class _RegisterMotherForm extends StatefulWidget {
  final TextEditingController codeController;
  final TextEditingController breedController;

  const _RegisterMotherForm({
    required this.codeController,
    required this.breedController,
  });

  @override
  State<_RegisterMotherForm> createState() => _RegisterMotherFormState();
}

class _RegisterMotherFormState extends State<_RegisterMotherForm> {
  bool isSaving = false;

  Future<String?> _getFarmId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['farmId'];
  }

  Future<void> saveMother() async {
    final code = widget.codeController.text.trim();
    final breed = widget.breedController.text.trim();

    if (code.isEmpty) {
      _showMessage('Ingrese el número de arete');
      return;
    }

    try {
      setState(() => isSaving = true);

      final farmId = await _getFarmId();

      if (farmId == null || farmId.isEmpty) {
        _showMessage('No se encontró la granja del usuario');
        return;
      }

      final motherRef = FirebaseFirestore.instance
          .collection('farms')
          .doc(farmId)
          .collection('mothers')
          .doc();

      await motherRef.set({
        'motherId': motherRef.id,
        'farmId': farmId,
        'code': code,
        'breed': breed,
        'reproductiveStatus': 'empty',
        'status': 'active',
        'historicalParturitions': 0,
        'totalBornAlive': 0,
        'totalWeaned': 0,
        'lifetimeMortalityRate': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);
      _showMessage('Madre registrada correctamente');
    } catch (e) {
      _showMessage('No se pudo registrar la madre');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Registrar madre',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.codeController,
            decoration: _inputDecoration(
              label: 'Número de arete',
              icon: Icons.tag_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.breedController,
            decoration: _inputDecoration(
              label: 'Raza / línea genética',
              icon: Icons.pets_rounded,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveMother,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'GUARDAR MADRE',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.light,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
