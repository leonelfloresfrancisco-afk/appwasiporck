import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          Text(
            '¿Necesitas ayuda? ',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),

          Text(
            'Contáctanos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
