import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _displayNameController;
  bool _isLoading = false;
  String? _error;
  String? _success;
  File? _profileImage;
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  String? _selectedAvatar;

  // Predefined avatars for privacy
  final List<String> _avatars = [
    '🦊', '🐱', '🐶', '🐼', '🐨', '🐯', '🦁', '🐸', '🐙', '🦄',
    '🐢', '🐬', '🦋', '🦅', '🦉', '🦒', '🐘', '🦔', '🐿️', '🦥',
    '🌟', '⭐', '🌙', '☀️', '🌈', '🍀', '🌸', '🌺', '🌻', '🌹',
    '🎭', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭',
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _displayNameController = TextEditingController(text: _getDisplayName(user));
    _loadProfileData();
  }

  String _getDisplayName(User? user) {
    if (user?.displayName == null || user!.displayName!.isEmpty) {
      final email = user?.email;
      if (email != null && email.isNotEmpty) {
        return email.split('@').first;
      }
      return 'User';
    }

    final nameParts = user.displayName!.trim().split(' ');
    if (nameParts.length >= 2) {
      return nameParts[1]; // Second name
    } else if (nameParts.length == 1) {
      return nameParts[0]; // First name
    }
    return 'User';
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _profileImageUrl = user.photoURL;
      });

      try {
        final doc = await FirestoreService().getUserProfile(user.uid);
        if (doc != null && doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['name'] != null) {
            _nameController.text = data['name'];
            _displayNameController.text = _getDisplayName(user);
          }
          if (data['avatar'] != null) {
            _selectedAvatar = data['avatar'];
          }
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _showAvatarSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAvatarPicker(),
    );
  }

  Widget _buildAvatarPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Choose Your Avatar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select an avatar to maintain your privacy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 320,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatars[index];
                      final isSelected = _selectedAvatar == avatar;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = avatar;
                            _profileImageUrl = null; // Clear custom image
                          });
                          Navigator.of(context).pop();
                          _saveAvatar();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickProfileImage();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Upload Photo', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAvatar() async {
    if (_selectedAvatar == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save avatar to Firestore
        FirestoreService().setUserProfile(
          userId: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          avatar: _selectedAvatar,
        );

        setState(() {
          _success = 'Avatar updated successfully!';
        });

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Avatar updated successfully!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update avatar. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _isUploadingImage = true;
        _selectedAvatar = null; // Clear avatar when uploading image
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _profileImage == null) return;

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture updated!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to upload profile picture.';
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Name cannot be empty.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();

        // Update Firestore profile
          FirestoreService().setUserProfile(
          userId: user.uid,
            name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          avatar: _selectedAvatar,
        );

        setState(() {
          _success = 'Profile updated successfully!';
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update profile. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send reset email. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    if (_profileImageUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF2196F3),
        backgroundImage: NetworkImage(_profileImageUrl!),
      );
    } else if (_selectedAvatar != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF2196F3),
        child: Text(
          _selectedAvatar!,
          style: const TextStyle(fontSize: 32),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF2196F3),
        child: Text(
          _getDisplayName(FirebaseAuth.instance.currentUser).isNotEmpty
              ? _getDisplayName(FirebaseAuth.instance.currentUser)[0].toUpperCase()
              : 'U',
          style: GoogleFonts.poppins(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IFoundAppBar(
          title: 'Profile',
          showLogo: true,
          actions: [
            if (!_isEditing)
              IconButton(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit Profile',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                      // Profile Picture/Avatar
                    Stack(
                      children: [
                          _buildProfileImage(),
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                              onTap: _isUploadingImage ? null : _showAvatarSelectionDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                      // User Info
                      Text(
                        _getDisplayName(user),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (user?.metadata.creationTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Member since ${user!.metadata.creationTime!.toLocal().toString().split(" ").first}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                                ),
                      ],
                    ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Profile Form
              if (_isEditing) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                        // Full Name Field
                    TextField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person_rounded),
                      ),
                    ),
                        const SizedBox(height: 12),

                        // Display Name Preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF404040) : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Display name: ${_getDisplayName(user)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                      ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                      ),
                              ],
                            ),
                          ),
                        ],

                        if (_success != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                        ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _success!,
                                    style: TextStyle(color: Colors.green[700]),
                      ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                        children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                          ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _isEditing = false;
                                    _error = null;
                                    _success = null;
                                    _nameController.text = user?.displayName ?? '';
                                  });
                                },
                            style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                          ),
                        ],
                      ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Account Actions
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lock_reset_rounded, color: Colors.blue[600], size: 20),
                      ),
                      title: const Text('Reset Password'),
                      subtitle: const Text('Send password reset email'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _resetPassword,
                    ),
                    Divider(height: 0, color: isDark ? const Color(0xFF404040) : Colors.grey[200]),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.logout_rounded, color: Colors.red[600], size: 20),
                      ),
                      title: const Text('Logout'),
                      subtitle: const Text('Sign out of your account'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}