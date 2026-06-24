import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscure,
      // Texto que escribe el usuario (más pequeño y estilizado)
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        // Estilo de la etiqueta cuando está quieta y cuando flota arriba
        labelStyle: const TextStyle(fontSize: 13),
        floatingLabelStyle: const TextStyle(fontSize: 12, height: 1.0),
        floatingLabelBehavior:
            FloatingLabelBehavior.auto, // Hace que flote de forma natural

        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical:
              12, // Equilibrio perfecto para que no se corte el texto verticalmente
        ),

        prefixIcon: const Icon(Icons.lock_outline, size: 18),

        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                obscure = !obscure;
              });
            },
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 14,
          ),
        ),

        // Espaciado interno controlado de los iconos para dar más espacio al texto
        suffixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
