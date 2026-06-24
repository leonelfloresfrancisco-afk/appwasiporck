import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45, // 🔽 REDUCIDO: antes 55
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 0,
          ), // 🆕 AÑADIDO: elimina padding vertical
          textStyle: const TextStyle(
            fontSize:
                14, // 🆕 AÑADIDO: texto más pequeño (antes 16 por defecto)
            fontWeight:
                FontWeight.w600, // 🆕 AÑADIDO: semibold en lugar de bold
          ),
        ),
        child: const Text('INICIAR SESIÓN'),
      ),
    );
  }
}
