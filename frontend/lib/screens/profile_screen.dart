import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:frontend/utils/image_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/image_upload_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImagePath;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from profile folder'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await ImageUploadService.pickImage(
                      ImageSource.gallery,
                    );
                    if (image != null && mounted) {
                      setState(() {
                        _uploadStatus = 'Uploading image...';
                      });

                      final String imagePath =
                          await ImageUploadService.uploadImage(
                            image,
                            type: 'profile',
                          );

                      if (ImageUtils.isValidImagePath(imagePath) && mounted) {
                        setState(() {
                          _profileImagePath = imagePath;
                          _uploadStatus = 'Image uploaded successfully!';
                        });
                        // Save the profile image path
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('profileImagePath', imagePath);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _uploadStatus = 'Error: $e';
                      });
                      _showError('Error uploading image: $e');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await ImageUploadService.pickImage(
                      ImageSource.camera,
                    );
                    if (image != null && mounted) {
                      setState(() {
                        _uploadStatus = 'Uploading image...';
                      });

                      final String imagePath =
                          await ImageUploadService.uploadImage(
                            image,
                            type: 'profile',
                          );

                      if (ImageUtils.isValidImagePath(imagePath) && mounted) {
                        setState(() {
                          _profileImagePath = imagePath;
                          _uploadStatus = 'Image uploaded successfully!';
                        });
                        // Save the profile image path
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('profileImagePath', imagePath);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _uploadStatus = 'Error: $e';
                      });
                      _showError('Error uploading image: $e');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (_profileImagePath == null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipOval(
        child: Image.file(
          File(_profileImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error, size: 60, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1E8449),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  _buildProfileImage(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8449),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_uploadStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _uploadStatus,
                  style: TextStyle(
                    color:
                        _uploadStatus.contains('successful')
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
