import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/google_auth_controller.dart';
import 'register_screen.dart';

import '../widgets/auth_footer.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
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
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthController authController = AuthController();

  final GoogleAuthController googleAuthController = GoogleAuthController();

  bool rememberMe = false;

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error de autenticación';

      if (e.code == 'user-not-found') {
        mensaje = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido';
      } else if (e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recuperación de contraseña próximamente')),
    );
  }

  Future<void> googleLogin() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await googleAuthController.signInWithGoogle();

      if (result == null) return;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const AuthLogo(),

                  const SizedBox(height: 20),

                  const AuthTitle(),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        EmailField(controller: emailController),

                        const SizedBox(height: 20),

                        PasswordField(controller: passwordController),

                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

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

                        const SizedBox(height: 20),

                        LoginButton(onPressed: login, isLoading: isLoading),

                        const SizedBox(height: 25),

                        Row(
                          children: [
                            const Expanded(child: Divider()),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),

                              child: Text(
                                'O',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),

                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const SizedBox(height: 20),

                        RegisterCard(onTap: register),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const AuthFooter(),

                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
