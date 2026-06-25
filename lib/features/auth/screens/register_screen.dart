import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wasipork/core/constants/app_colors.dart';
import 'package:wasipork/core/navigation/main_navigation_screen.dart';

import '../controllers/register_controller.dart';
import '../controllers/google_auth_controller.dart';
import '../widgets/email_field.dart';
import '../widgets/first_name_field.dart';
import '../widgets/last_name_field.dart';
import '../widgets/password_field.dart';
import '../widgets/confirm_password_field.dart';
import '../widgets/phone_field.dart';
import '../widgets/google_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final registerController = RegisterController();
  final googleAuthController = GoogleAuthController();

  bool acceptedTerms = false;
  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> register() async {
    if (firstNameController.text.trim().isEmpty) {
      showMessage('Ingrese sus nombres');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      showMessage('Ingrese sus apellidos');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      showMessage('Ingrese su correo');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Ingrese su número de teléfono');
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      showMessage('Ingrese una contraseña');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage('Las contraseñas no coinciden');
      return;
    }

    if (!acceptedTerms) {
      showMessage('Debe aceptar los términos y condiciones');
      return;
    }

    try {
      setState(() => isLoading = true);

      await registerController.register(
        nombres: firstNameController.text.trim(),
        apellidos: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        telefono: phoneController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrar usuario';

      if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil';
      } else if (e.code == 'invalid-email') {
        message = 'Correo inválido';
      }

      if (!mounted) return;
      showMessage(message);
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> googleRegister() async {
    try {
      setState(() => isLoading = true);

      final UserCredential? credential = await googleAuthController
          .signInWithGoogle();

      if (credential == null) return;

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showMessage('Error Google: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void goLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: goLogin,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.primary,
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          children: [
            RichText(
              textAlign: TextAlign.left,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Registro en ',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      height: 1.15,
                    ),
                  ),
                  TextSpan(
                    text: 'Wasi',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1.15,
                    ),
                  ),
                  TextSpan(
                    text: 'Porck',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Crea tu acceso para gestionar madres, partos y alertas.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: FirstNameField(controller: firstNameController),
                ),
                const SizedBox(width: 10),
                Expanded(child: LastNameField(controller: lastNameController)),
              ],
            ),

            const SizedBox(height: 12),
            EmailField(controller: emailController),

            const SizedBox(height: 12),
            PhoneField(controller: phoneController),

            const SizedBox(height: 12),
            PasswordField(controller: passwordController),

            const SizedBox(height: 12),
            ConfirmPasswordField(controller: confirmPasswordController),

            const SizedBox(height: 4),

            CheckboxListTile(
              value: acceptedTerms,
              onChanged: (value) {
                setState(() => acceptedTerms = value ?? false);
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos y Políticas',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CREAR CUENTA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'O',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 14),

            GoogleButton(onPressed: isLoading ? () {} : googleRegister),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
