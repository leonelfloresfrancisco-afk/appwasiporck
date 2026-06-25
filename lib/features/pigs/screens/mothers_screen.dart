import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../reproduction/screens/register_actions_screen.dart';
import '../models/mother_model.dart';
import '../services/mother_service.dart';

class MothersScreen extends StatelessWidget {
  MothersScreen({super.key});

  final MotherService _motherService = MotherService();

  Future<String?> _getFarmId() {
    return _motherService.getFarmId();
  }

  Stream<List<MotherModel>> _mothersStream(String farmId) {
    return _motherService.watchMothers(farmId);
  }

  void _goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterActionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToRegister(context),
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
                            'Registra tu primera cerda reproductora desde el módulo Registrar.',
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
            label: 'Gestación',
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
      height: 104,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1,
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
    if (mother.status == 'dead') return AppColors.danger;
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ChipLabel(text: statusText, color: statusColor),
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
