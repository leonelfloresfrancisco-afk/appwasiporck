import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../controllers/register_controller.dart';
import '../controllers/google_auth_controller.dart'; // 🔽 Agregado
import '../../../core/constants/app_colors.dart';
import '../widgets/auth_logo.dart';
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool acceptedTerms = false;
  bool isLoading = false;

  final RegisterController registerController = RegisterController();
  final GoogleAuthController googleAuthController =
      GoogleAuthController(); // 🔽 Agregado

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese sus nombres')));
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese sus apellidos')));
      return;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese su correo')));
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese su número de teléfono')),
      );
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese una contraseña')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await registerController.register(
        nombres: firstNameController.text.trim(),
        apellidos: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        telefono: phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
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

  // 🔄 Reemplazado por completo el método de autenticación con Google
  Future<void> googleRegister() async {
    try {
      setState(() {
        isLoading = true;
      });

      final UserCredential? credential = await googleAuthController
          .signInWithGoogle();

      if (credential == null) {
        return;
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Google: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const AuthLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus datos para comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: FirstNameField(controller: firstNameController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LastNameField(controller: lastNameController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  EmailField(controller: emailController),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: PasswordField(controller: passwordController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ConfirmPasswordField(
                          controller: confirmPasswordController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PhoneField(controller: phoneController),
                  const SizedBox(height: 12),

                  // ================= COMPONENTE DESPLEGABLE LEGAL =================
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(
                        left: 48,
                        right: 12,
                        bottom: 8,
                      ),
                      trailing: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey,
                      ),
                      leading: Checkbox(
                        value: acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      title: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                          children: [
                            TextSpan(text: 'Acepto los '),
                            TextSpan(
                              text: 'Términos, Condiciones y Políticas',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        RichText(
                          textAlign: TextAlign.justify,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'Autorizo de manera previa, libre, expresa e inequívoca el almacenamiento y tratamiento de mis datos personales en su banco de datos, así como el envío de alertas, publicidad y notificaciones comerciales a través de correo electrónico, SMS, llamadas telefónicas, ',
                              ),
                              TextSpan(
                                text:
                                    'redes sociales y demás canales de comunicación digital',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ', conforme a la Ley N° 29733 (Ley de Protección de Datos Personales del Perú) y su Política de Privacidad.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================================
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('REGISTRARME'),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 🎯 Botón modificado para controlar el estado de carga (isLoading)
                  GoogleButton(onPressed: isLoading ? () {} : googleRegister),

                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
