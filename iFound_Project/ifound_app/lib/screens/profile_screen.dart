import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool editing = false;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  bool _isLoading = false;
  String? _error;
  String? _success;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  File? _profileImage;
  String? _profileImageUrl;
  bool _isVerifying = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController = TextEditingController(text: user?.displayName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null) {
      setState(() {
        _profileImageUrl = user.photoURL;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _profileImage == null) return;
    setState(() => _isLoading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
      await ref.putFile(_profileImage!);
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      await user.reload();
      setState(() {
        _profileImageUrl = url;
        _success = 'Profile picture updated!';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      setState(() => _error = 'Failed to upload profile picture.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());
        await user.reload();
        setState(() {
          _success = 'Profile updated!';
          editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update profile.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
    } catch (e) {
      setState(() => _error = 'Failed to send password reset email.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmail() async {
    setState(() => _isVerifying = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent.')));
      }
    } catch (e) {
      setState(() => _error = 'Failed to send verification email.');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted.')));
    } catch (e) {
      setState(() => _error = 'Failed to delete account.');
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final joinDate = user?.metadata.creationTime;
    final lastLogin = user?.metadata.lastSignInTime;
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IFoundAppBar(
          title: 'Profile',
        ),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF2196F3),
                          backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                          child: _profileImageUrl == null
                              ? Text(
                                  nameController.text.isNotEmpty ? nameController.text[0] : '',
                                  style: GoogleFonts.poppins(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt_rounded, color: Color(0xFF2196F3), size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (user != null && !user.emailVerified)
                      Card(
                        color: Colors.amber[100],
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                          title: const Text('Email not verified'),
                          subtitle: const Text('Please verify your email.'),
                          trailing: _isVerifying
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : TextButton(
                                  onPressed: _verifyEmail,
                                  child: const Text('Resend'),
                                ),
                        ),
                      ),
                    TextField(
                      controller: nameController,
                      enabled: editing && !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (joinDate != null)
                      Text('Joined: ${joinDate.toLocal().toString().split(" ").first}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (lastLogin != null)
                      Text('Last login: ${lastLogin.toLocal().toString().split(" ").first}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    if (_success != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_success!, style: const TextStyle(color: Colors.green)),
                      ),
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    if (!editing)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => setState(() => editing = true),
                        child: const Text('Edit Profile'),
                      ),
                    if (editing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveProfile,
                            child: const Text('Save'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading ? null : () => setState(() => editing = false),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _changePassword,
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: const Text('Change Password'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isDeleting
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: const Text('Are you sure you want to delete your account? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _deleteAccount();
                              }
                            },
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: _isDeleting ? const Text('Deleting...') : const Text('Delete Account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}