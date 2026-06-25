import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController lactationDaysController = TextEditingController();
  final TextEditingController gestationDaysController = TextEditingController();
  final TextEditingController estrusStartController = TextEditingController();
  final TextEditingController estrusEndController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  String userName = 'Usuario';
  String email = '';
  String farmId = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    farmNameController.dispose();
    locationController.dispose();
    lactationDaysController.dispose();
    gestationDaysController.dispose();
    estrusStartController.dispose();
    estrusEndController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      final userData = userDoc.data();

      farmId = userData?['farmId'] ?? '';
      email = user.email ?? '';

      final nombres = userData?['nombres']?.toString() ?? '';
      final apellidos = userData?['apellidos']?.toString() ?? '';

      userName = '$nombres $apellidos'.trim();

      if (userName.isEmpty) {
        userName = user.displayName ?? 'Usuario';
      }

      if (farmId.isNotEmpty) {
        final farmDoc = await _firestore.collection('farms').doc(farmId).get();

        final farmData = farmDoc.data();
        final settings = farmData?['settings'] ?? {};

        farmNameController.text = farmData?['name'] ?? 'Mi Granja';
        locationController.text = farmData?['location'] ?? '';

        lactationDaysController.text = '${settings['lactationDays'] ?? 21}';
        gestationDaysController.text = '${settings['gestationDays'] ?? 114}';
        estrusStartController.text =
            '${settings['estrusStartDayAfterWeaning'] ?? 3}';
        estrusEndController.text =
            '${settings['estrusEndDayAfterWeaning'] ?? 7}';
      }
    } catch (e) {
      showMessage('No se pudo cargar el perfil');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveProfile() async {
    if (farmId.isEmpty) {
      showMessage('No se encontró la granja del usuario');
      return;
    }

    try {
      setState(() => isSaving = true);

      await _firestore.collection('farms').doc(farmId).update({
        'name': farmNameController.text.trim(),
        'location': locationController.text.trim(),
        'settings': {
          'lactationDays':
              int.tryParse(lactationDaysController.text.trim()) ?? 21,
          'gestationDays':
              int.tryParse(gestationDaysController.text.trim()) ?? 114,
          'estrusStartDayAfterWeaning':
              int.tryParse(estrusStartController.text.trim()) ?? 3,
          'estrusEndDayAfterWeaning':
              int.tryParse(estrusEndController.text.trim()) ?? 7,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      showMessage('Configuración guardada correctamente');
    } catch (e) {
      showMessage('No se pudo guardar la configuración');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.light,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 16),

            _UserCard(userName: userName, email: email),

            const SizedBox(height: 18),

            const _SectionTitle(title: 'Datos de la granja'),

            const SizedBox(height: 12),

            _InputField(
              controller: farmNameController,
              label: 'Nombre de la granja',
              icon: Icons.agriculture_rounded,
            ),

            const SizedBox(height: 12),

            _InputField(
              controller: locationController,
              label: 'Ubicación',
              icon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 18),

            const _SectionTitle(title: 'Parámetros reproductivos'),

            const SizedBox(height: 12),

            _InputField(
              controller: gestationDaysController,
              label: 'Días de gestación',
              icon: Icons.calendar_month_rounded,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            _InputField(
              controller: lactationDaysController,
              label: 'Días de lactancia',
              icon: Icons.child_care_rounded,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _InputField(
                    controller: estrusStartController,
                    label: 'Inicio celo',
                    icon: Icons.favorite_border_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    controller: estrusEndController,
                    label: 'Fin celo',
                    icon: Icons.favorite_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
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
                        'GUARDAR CONFIGURACIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String userName;
  final String email;

  const _UserCard({required this.userName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
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
            color: AppColors.dark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
