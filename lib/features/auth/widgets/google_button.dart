import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45, // 🔽 REDUCIDO: antes 55
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 🔽 REDUCIDO: antes 12
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 0,
          ), // 🆕 AÑADIDO: elimina padding vertical
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICONO GOOGLE
            Image.asset(
              AppAssets.googleIcon,
              width: 20, // 🔽 REDUCIDO: antes 24
              height: 20, // 🔽 REDUCIDO: antes 24
            ),
            const SizedBox(width: 10), // 🔽 REDUCIDO: antes 12
            const Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 13, // 🔽 REDUCIDO: antes 15
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
