// profil.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'firebase_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePicker();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController softSkillsController = TextEditingController();
  final TextEditingController hardSkillsController = TextEditingController();

  String fullName = '';
  String username = '';
  String profileImageUrl = '';
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  bool _isCheckingUsername = false;
  String? _errorMessage;
  String? _usernameError;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    softSkillsController.dispose();
    hardSkillsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProfile = await _firebaseService.getUserProfile();

      if (userProfile != null) {
        setState(() {
          fullName = '${userProfile['firstName'] ?? ''} ${userProfile['lastName'] ?? ''}'.trim();
          if (fullName.isEmpty) {
            fullName = _firebaseService.currentUser?.displayName ?? 'User Name';
          }
          
          username = userProfile['username'] ?? '';
          usernameController.text = username;
          emailController.text = userProfile['email'] ?? _firebaseService.currentUser?.email ?? '';
          phoneController.text = userProfile['phone'] ?? '';
          softSkillsController.text = userProfile['softSkills'] ?? '';
          hardSkillsController.text = userProfile['hardSkills'] ?? '';
          
          // Set profile image URL
          profileImageUrl = userProfile['profilePictureUrl'] ?? 
                           _firebaseService.currentUser?.photoURL ?? '';
        });
      } else {
        // If no profile found, use current user data
        final currentUser = _firebaseService.currentUser;
        if (currentUser != null) {
          setState(() {
            fullName = currentUser.displayName ?? 'User Name';
            emailController.text = currentUser.email ?? '';
            profileImageUrl = currentUser.photoURL ?? '';
            username = '';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
      });
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
      });
      return false;
    }

    // Check if username contains only allowed characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Username can only contain letters, numbers, and underscores';
      });
      return false;
    }

    try {
      setState(() {
        _isCheckingUsername = true;
        _usernameError = null;
      });

      // Skip check if it's the same as current username
      if (username.toLowerCase() == this.username.toLowerCase()) {
        setState(() {
          _isCheckingUsername = false;
        });
        return true;
      }

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      setState(() {
        _isCheckingUsername = false;
      });

      if (result.docs.isNotEmpty) {
        setState(() {
          _usernameError = 'Username is already taken';
        });
        return false;
      }

      setState(() {
        _usernameError = null;
      });
      return true;
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError = 'Error checking username availability';
      });
      return false;
    }
  }

  Future<void> _updateProfile() async {
    // Validate username before updating
    if (usernameController.text.trim().isNotEmpty) {
      bool isUsernameValid = await _checkUsernameAvailability(usernameController.text.trim());
      if (!isUsernameValid) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prepare update data
      Map<String, dynamic> updateData = {
        'username': usernameController.text.trim().toLowerCase(),
        'phone': phoneController.text.trim(),
        'softSkills': softSkillsController.text.trim(),
        'hardSkills': hardSkillsController.text.trim(),
        'updatedAt': DateTime.now(),
      };

      // Upload image if selected
      if (_selectedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });
        
        final imageUrl = await _uploadProfileImage(_selectedImage!);
        if (imageUrl != null) {
          updateData['profilePictureUrl'] = imageUrl;
          // Update Firebase Auth profile as well
          await _firebaseService.currentUser?.updatePhotoURL(imageUrl);
          setState(() {
            profileImageUrl = imageUrl;
          });
        }
        
        setState(() {
          _isUploadingImage = false;
        });
      }

      await _firebaseService.updateUserProfile(updateData);

      setState(() {
        _isEditing = false;
        _selectedImage = null;
        username = usernameController.text.trim().toLowerCase();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
        _isUploadingImage = false;
      });
      print('Error updating profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return null;

      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);
      
      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: const Text('Choose how you want to select your new profile picture.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Camera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Gallery'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.purple[100],
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!) as ImageProvider
              : (profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl) as ImageProvider
                  : null),
          child: (profileImageUrl.isEmpty && _selectedImage == null)
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.purple[300],
                )
              : null,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (_isUploadingImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets1/gambar-removebg-preview.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text("SmartComp"),
          ],
        ),
        backgroundColor: Colors.purple[200],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: const Text("Dashboard", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
            child: const Text("About", style: TextStyle(color: Colors.black)),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Toggle Buttons
                    ToggleButtons(
                      isSelected: [true, false],
                      onPressed: (index) {
                        if (index == 1) {
                          Navigator.pushNamed(context, '/job');
                        }
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Profile"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Job"),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Profile Picture with Camera Feature
                    _buildProfileImage(),
                    SizedBox(height: 20),

                    // User Name and Username
                    Text(
                      fullName.isNotEmpty ? fullName : 'User Name',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (username.isNotEmpty)
                      Text(
                        '@$username',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Form Fields
                    buildLabel('Username'),
                    buildUsernameField(),

                    buildLabel('Email'),
                    buildTextField(emailController, readOnly: true),

                    buildLabel('Phone'),
                    buildTextField(phoneController, readOnly: !_isEditing),

                    buildLabel('Soft Skills'),
                    buildTextField(
                      softSkillsController,
                      readOnly: !_isEditing,
                      maxLines: 3,
                      hintText: 'Enter your soft skills (e.g., Communication, Leadership, Problem Solving)',
                    ),

                    buildLabel('Hard Skills'),
                    buildTextField(
                      hardSkillsController,
                      readOnly: !_isEditing,
                      maxLines: 3,
                      hintText: 'Enter your hard skills (e.g., Programming, Design, Marketing)',
                    ),

                    SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!_isEditing)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                                _errorMessage = null;
                                _usernameError = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[50],
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        if (_isEditing) ...[
                          ElevatedButton(
                            onPressed: _isUploadingImage || _isCheckingUsername || _usernameError != null 
                                ? null 
                                : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                          ElevatedButton(
                            onPressed: _isUploadingImage || _isCheckingUsername ? null : () {
                              setState(() {
                                _isEditing = false;
                                _selectedImage = null;
                                _errorMessage = null;
                                _usernameError = null;
                              });
                              _loadUserProfile(); // Reload original data
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 20),

                    // Account Management Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Management',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email Verified'),
                              subtitle: Text(
                                  _firebaseService.currentUser?.emailVerified ?? false
                                      ? 'Your email is verified'
                                      : 'Please verify your email'),
                              trailing: _firebaseService.currentUser?.emailVerified ?? false
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : TextButton(
                                      onPressed: () async {
                                        try {
                                          await _firebaseService.currentUser?.sendEmailVerification();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Verification email sent!')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Failed to send verification email'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Verify'),
                                    ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.security),
                              title: const Text('Change Password'),
                              subtitle: const Text('Update your password'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                _showChangePasswordDialog();
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                              subtitle: const Text('Permanently delete your account'),
                              onTap: () {
                                _showDeleteAccountDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: usernameController,
          readOnly: !_isEditing,
          onChanged: _isEditing ? (value) {
            if (value.isNotEmpty) {
              // Debounce username checking
              Future.delayed(const Duration(milliseconds: 500), () {
                if (usernameController.text == value) {
                  _checkUsernameAvailability(value);
                }
              });
            } else {
              setState(() {
                _usernameError = null;
              });
            }
          } : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: !_isEditing ? Colors.grey[200] : Colors.white,
            hintText: 'Enter your unique username',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixText: '@',
            prefixStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: _isCheckingUsername
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_usernameError == null && usernameController.text.isNotEmpty && _isEditing
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _usernameError != null ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _usernameError != null ? Colors.red : Colors.purple[300]!,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        if (_usernameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _usernameError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_isEditing && _usernameError == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Username must be unique and at least 3 characters',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final credential = EmailAuthProvider.credential(
                    email: _firebaseService.currentUser!.email!,
                    password: currentPasswordController.text,
                  );
                  await _firebaseService.currentUser!.reauthenticateWithCredential(credential);
                  await _firebaseService.currentUser!.updatePassword(newPasswordController.text);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update password: ${e.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This action cannot be undone. Please enter your password to confirm.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final credential = EmailAuthProvider.credential(
                    email: _firebaseService.currentUser!.email!,
                    password: passwordController.text,
                  );
                  await _firebaseService.currentUser!.reauthenticateWithCredential(credential);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_firebaseService.currentUser!.uid)
                      .delete();

                  await _firebaseService.currentUser!.delete();

                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete account: ${e.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[300]!),
        ),
      ),
    );
  }
}