import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<String> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Usuario';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return user.displayName ?? 'Usuario';

    final data = doc.data();
    final nombres = data?['nombres']?.toString().trim() ?? '';

    if (nombres.isNotEmpty) {
      return nombres.split(' ').take(2).join(' ');
    }

    return user.displayName ?? 'Usuario';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final data = DashboardData.empty();

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loadUserName(),
          builder: (context, snapshot) {
            final userName = snapshot.data ?? 'Usuario';

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              children: [
                _TopHeader(
                  greeting: _greeting(),
                  userName: userName,
                  pendingAlerts: data.pendingAlerts,
                ),
                const SizedBox(height: 14),
                _ExecutiveSummary(data: data),
                const SizedBox(height: 14),
                _MainAlertCard(data: data),
                const SizedBox(height: 14),
                _SmallInfoRow(data: data),
                const SizedBox(height: 18),
                const _SectionTitle(title: 'Acciones rápidas'),
                const SizedBox(height: 10),
                const _QuickActionsGrid(),
                const SizedBox(height: 18),
                const _SectionTitle(title: 'Actividad reciente'),
                const SizedBox(height: 10),
                _RecentActivityCard(data: data),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardData {
  final int pendingAlerts;
  final int todayTasks;
  final int upcomingBirths;
  final int fertileMothers;
  final int activeMothers;
  final int pregnantMothers;
  final int lactatingMothers;
  final int vaccinesDue;
  final String criticalMotherCode;
  final String criticalAction;
  final String fertileMotherCode;
  final String fertileDate;
  final List<String> recentActivities;

  const DashboardData({
    required this.pendingAlerts,
    required this.todayTasks,
    required this.upcomingBirths,
    required this.fertileMothers,
    required this.activeMothers,
    required this.pregnantMothers,
    required this.lactatingMothers,
    required this.vaccinesDue,
    required this.criticalMotherCode,
    required this.criticalAction,
    required this.fertileMotherCode,
    required this.fertileDate,
    required this.recentActivities,
  });

  factory DashboardData.empty() {
    return const DashboardData(
      pendingAlerts: 0,
      todayTasks: 0,
      upcomingBirths: 0,
      fertileMothers: 0,
      activeMothers: 0,
      pregnantMothers: 0,
      lactatingMothers: 0,
      vaccinesDue: 0,
      criticalMotherCode: 'Sin alerta crítica',
      criticalAction: 'No hay acciones críticas pendientes.',
      fertileMotherCode: 'Sin madre fértil',
      fertileDate: 'Pendiente',
      recentActivities: ['Aún no hay actividad registrada'],
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final int pendingAlerts;

  const _TopHeader({
    required this.greeting,
    required this.userName,
    required this.pendingAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final cleanName = userName.trim().isEmpty ? 'Usuario' : userName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$greeting, ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                TextSpan(
                  text: cleanName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(
                  text: '\nWasi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    height: 1.25,
                  ),
                ),
                const TextSpan(
                  text: 'Porck',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.danger,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
              ),
            ),
            if (pendingAlerts > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    pendingAlerts > 99 ? '99+' : '$pendingAlerts',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ExecutiveSummary extends StatelessWidget {
  final DashboardData data;

  const _ExecutiveSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: AppColors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Vista rápida del criadero',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryNumber(value: data.activeMothers, label: 'Madres'),
              const _SummaryDivider(),
              _SummaryNumber(value: data.pregnantMothers, label: 'Gestantes'),
              const _SummaryDivider(),
              _SummaryNumber(value: data.lactatingMothers, label: 'Lactancia'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${data.todayTasks} tareas · ${data.upcomingBirths} partos · ${data.fertileMothers} en celo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryNumber extends StatelessWidget {
  final int value;
  final String label;

  const _SummaryNumber({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.white.withOpacity(0.22),
    );
  }
}

class _MainAlertCard extends StatelessWidget {
  final DashboardData data;

  const _MainAlertCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PriorityCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.danger,
            title: 'Crítico',
            value: data.criticalMotherCode,
            subtitle: data.criticalAction,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PriorityCard(
            icon: Icons.favorite_rounded,
            color: AppColors.primary,
            title: 'Celo',
            value: data.fertileMotherCode,
            subtitle: 'Fecha: ${data.fertileDate}',
          ),
        ),
      ],
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _PriorityCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 158),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.25,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallInfoRow extends StatelessWidget {
  final DashboardData data;

  const _SmallInfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallInfoCard(
            icon: Icons.notifications_active_rounded,
            value: '${data.pendingAlerts}',
            label: 'Alertas',
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallInfoCard(
            icon: Icons.vaccines_rounded,
            value: '${data.vaccinesDue}',
            label: 'Vacunas',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallInfoCard(
            icon: Icons.analytics_outlined,
            value: '0%',
            label: 'Mortalidad',
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SmallInfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            borderRadius: BorderRadius.circular(50),
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

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: const [
        _QuickAction(icon: Icons.add_circle_outline_rounded, title: 'Madre'),
        _QuickAction(icon: Icons.biotech_rounded, title: 'Inseminar'),
        _QuickAction(icon: Icons.pregnant_woman_rounded, title: 'Parto'),
        _QuickAction(icon: Icons.child_care_rounded, title: 'Destete'),
        _QuickAction(icon: Icons.healing_rounded, title: 'Baja'),
        _QuickAction(icon: Icons.vaccines_rounded, title: 'Vacunas'),
        _QuickAction(icon: Icons.medication_rounded, title: 'Medicina'),
        _QuickAction(icon: Icons.analytics_outlined, title: 'Reportes'),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickAction({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final DashboardData data;

  const _RecentActivityCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: data.recentActivities
            .map(
              (activity) => ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                title: Text(
                  activity,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
