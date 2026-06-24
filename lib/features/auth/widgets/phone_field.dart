import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ), // Texto de usuario compacto
      // VALIDADOR: Hace que el campo sea obligatorio al validar el Form
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El número de teléfono es obligatorio';
        }
        // Opcional: Puedes validar que tenga 9 dígitos (estándar de Perú)
        if (value.trim().length < 9) {
          return 'Ingrese un número válido';
        }
        return null;
      },

      decoration: InputDecoration(
        labelText: 'Teléfono', // 🔽 Cambiado: Ya no es opcional
        labelStyle: const TextStyle(fontSize: 13),
        floatingLabelStyle: const TextStyle(fontSize: 12, height: 1.0),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12, // Altura interna consistente para evitar cortes
        ),

        prefixIcon: const Icon(
          Icons.phone_outlined,
          size: 18, // Consistente con tus inputs de contraseña
        ),

        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Mismo radio de borde de tu diseño actual
        ),

        // Estilo fino para el texto de error si falta rellenar
        errorStyle: const TextStyle(fontSize: 11, height: 0.8),
      ),
    );
  }
}
