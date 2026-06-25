import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wasipork/core/constants/app_colors.dart';
import 'package:wasipork/core/navigation/main_navigation_screen.dart';

import '../controllers/auth_controller.dart';
import 'register_screen.dart';

import '../widgets/auth_logo.dart';
import '../widgets/email_field.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/login_button.dart';
import '../widgets/password_field.dart';
import '../widgets/register_card.dart';
import '../widgets/remember_me.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authController = AuthController();

  bool rememberMe = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> login() async {
    try {
      setState(() => isLoading = true);

      await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Correo o contraseña incorrectos';

      if (e.code == 'invalid-email') {
        message = 'Correo inválido';
      } else if (e.code == 'user-not-found') {
        message = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-credential') {
        message = 'Correo o contraseña incorrectos';
      }

      if (!mounted) return;
      showMessage(message);
    } catch (_) {
      if (!mounted) return;
      showMessage('No se pudo iniciar sesión');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void forgotPassword() {
    showMessage('Recuperación de contraseña próximamente');
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            const SizedBox(height: 20),

            const Center(child: AuthLogo()),

            const SizedBox(height: 28),

            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Bienvenido a ',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      letterSpacing: -0.6,
                    ),
                  ),
                  TextSpan(
                    text: 'Wasi',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  TextSpan(
                    text: 'Porck',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Control reproductivo, alertas sanitarias y productividad de madres porcinas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 36),

            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 18),

            EmailField(controller: emailController),

            const SizedBox(height: 16),

            PasswordField(controller: passwordController),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: RememberMe(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),
                ),
                ForgotPasswordLink(onTap: forgotPassword),
              ],
            ),

            const SizedBox(height: 24),

            LoginButton(
              onPressed: isLoading ? () {} : login,
              isLoading: isLoading,
            ),

            const SizedBox(height: 18),

            RegisterCard(onTap: register),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
