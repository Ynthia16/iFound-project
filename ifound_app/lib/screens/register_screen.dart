import 'package:flutter/material.dart';
import '../components/ifound_logo.dart';
import '../components/ifound_textfield.dart';
import '../components/ifound_button.dart';
import '../services/auth_service.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 24.0;
    final logoSize = isSmallScreen ? 80.0 : 100.0;
    final titleSize = isSmallScreen ? 24.0 : 28.0;
    final verticalPadding = isSmallScreen ? 20.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: verticalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isSmallScreen ? 20 : 40),
                IFoundLogo(size: logoSize),
                SizedBox(height: isSmallScreen ? 20 : 32),
                Text(
                  'create_account'.tr(),
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 32),
                IFoundTextField(
                  label: 'full_name'.tr(),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Please enter your full name (first and last name)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
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
                SizedBox(height: isSmallScreen ? 16 : 20),
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
                SizedBox(height: isSmallScreen ? 24 : 32),
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                    child: const CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  IFoundButton(
                    text: 'Register',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isLoading = true);
                      try {
                        final userCredential = await authService.createUserWithEmailAndPassword(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                        );

                        if (userCredential != null) {
                          // Show success message and navigate to login
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ Account created successfully! Please sign in.'.tr()),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            // Navigate back to login screen after successful registration
                            Navigator.of(context).pop();
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showErrorDialog(e.toString());
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}