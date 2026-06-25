import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pigs/screens/mothers_screen.dart';
import '../../features/reproduction/screens/register_actions_screen.dart';
import '../../features/health/screens/alerts_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  final int alertCount;

  const MainNavigationScreen({super.key, this.alertCount = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    MothersScreen(),
    RegisterActionsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: _ProfessionalBottomNav(
        currentIndex: currentIndex,
        alertCount: widget.alertCount,
        onTap: changeTab,
      ),
    );
  }
}

class _ProfessionalBottomNav extends StatelessWidget {
  final int currentIndex;
  final int alertCount;
  final ValueChanged<int> onTap;

  const _ProfessionalBottomNav({
    required this.currentIndex,
    required this.alertCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 72 + bottomPadding,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: bottomPadding > 0 ? bottomPadding : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Inicio',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.pets_outlined,
              activeIcon: Icons.pets_rounded,
              label: 'Madres',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _CenterRegisterButton(
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.notifications_none_rounded,
              activeIcon: Icons.notifications_rounded,
              label: 'Alertas',
              isActive: currentIndex == 3,
              badgeCount: alertCount,
              onTap: () => onTap(3),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterRegisterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterRegisterButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color textColor = isActive ? AppColors.primary : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 2),
          Text(
            'Registrar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.primary : Colors.grey.shade700;
    final int safeBadge = badgeCount < 0 ? 0 : badgeCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(isActive ? activeIcon : icon, color: color, size: 24),
              if (safeBadge > 0)
                Positioned(
                  right: -9,
                  top: -7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      safeBadge > 99 ? '99+' : '$safeBadge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
