import 'package:flutter/material.dart';
import '../components/ifound_logo.dart';
import '../components/ifound_textfield.dart';
import '../components/ifound_button.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import '../services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

/// Register screen for new user sign up.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IFoundLogo(size: 80),
                const SizedBox(height: 24),
                Text(
                  'create_account'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 24),
                IFoundTextField(
                  label: 'full_name'.tr(),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'full_name' + ' required';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'full_name' + ' min 2';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                IFoundTextField(
                  label: 'email'.tr(),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                IFoundTextField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  IFoundButton(
                    text: 'Register',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isLoading = true);
                      try {
                        final userCredential = await authService.signUpWithEmail(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        // Save display name
                        await userCredential.user?.updateDisplayName(nameController.text.trim());
                        // adding a  need to log in again, user is already signed in
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const MainShell()),
                        );
                      } catch (e) {
                        _showErrorDialog(e.toString());
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}