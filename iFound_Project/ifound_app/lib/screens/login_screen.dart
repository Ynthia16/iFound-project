import 'package:flutter/material.dart';
import '../components/ifound_logo.dart';
import '../components/ifound_textfield.dart';
import '../components/ifound_button.dart';
import 'register_screen.dart';
import 'main_shell.dart';
import '../services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Login screen for user authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: resetEmailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password reset logic
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Check your email'),
                  content: const Text('A password reset link has been sent if the email exists.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
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
                  'Login to iFound',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 24),
                IFoundTextField(
                  label: 'Email',
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading) ...[
                  IFoundButton(
                    text: 'Login',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isLoading = true);
                      try {
                        await authService.signInWithEmail(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
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
                  const SizedBox(height: 12),
                  IFoundButton(
                    text: 'Sign in with Google',
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        await authService.signInWithGoogle();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const MainShell()),
                        );
                      } catch (e) {
                        _showErrorDialog(e.toString());
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    icon: SvgPicture.network(
                      'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png', //refine this better
                      height: 24,
                      width: 24,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "Don't have an account? Register",
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