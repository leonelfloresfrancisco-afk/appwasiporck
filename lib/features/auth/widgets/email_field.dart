import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'correo@ejemplo.com',
        prefixIcon: const Icon(
          Icons.email_outlined,
          size: 20,
        ), // 🔽 REDUCIDO: antes 24
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 🔽 REDUCIDO: antes 14
        ),
        contentPadding: const EdgeInsets.symmetric(
          // 🆕 AÑADIDO: para reducir espacio interno
          horizontal: 12, // 🔽 REDUCIDO: antes 16
          vertical: 10, // 🔽 REDUCIDO: antes 14
        ),
        isDense: true, // 🆕 AÑADIDO: compacta el campo
      ),
    );
  }
}
