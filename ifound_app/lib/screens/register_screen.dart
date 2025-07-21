import 'package:flutter/material.dart';
import '../components/ifound_logo.dart';
import '../components/ifound_textfield.dart';
import '../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  style: GoogleFonts.poppins(
                    fontSize: 22, // was 24/28
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        minimumSize: const Size.fromHeight(48), // 48dp height
                      ),
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
                            // Sign out the user immediately after registration
                            await FirebaseAuth.instance.signOut();
                            
                            // Show success message and navigate to login
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('\u2705 Account created successfully! Please sign in.'.tr(), style: GoogleFonts.poppins(fontSize: 14)),
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
                      child: Text(
                        'Register',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF2196F3),
                      fontSize: 14,
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