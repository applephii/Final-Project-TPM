import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybuddy/sevices/photo_api.dart';
import 'package:studybuddy/sevices/profile_api.dart';
import 'package:studybuddy/sevices/session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isDataLoaded = false;
  bool _isUploading = false;
  File? _selectedImage;
  String? _currentPhotoUrl;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final username = await SessionService.getUsername();
    final email = await SessionService.getEmail();
    final userId = await SessionService.getUserId();

    String? photoUrl;
    if (userId != null) {
      photoUrl = await PhotoApi.getProfilePhotoUrl(userId);
    }

    if (photoUrl == null || photoUrl.isEmpty) {
      await SessionService.savePhotoUrl('');
    }

    setState(() {
      _username.text = username ?? '';
      _email.text = email ?? '';
      _currentPhotoUrl = photoUrl;
      _isDataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final success = await ProfileApi.updateUser(
        username: _username.text.trim().isNotEmpty
            ? _username.text.trim()
            : null,
        email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
        password: _password.text.trim().isNotEmpty
            ? _password.text.trim()
            : null,
      );

      if (!success) {
        throw Exception('Failed to update profile');
      }

      if (_selectedImage != null) {
        final photoUrl = await PhotoApi.uploadPhoto(userId, _selectedImage!);
        debugPrint('cek photourl di edit page: $photoUrl');
        if (photoUrl != null) throw Exception('Failed to upload photo');

        final timestampedUrl =
            "$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}";
        _currentPhotoUrl = timestampedUrl;
        await SessionService.savePhotoUrl(timestampedUrl);
      }

      await SessionService.setUsername(_username.text.trim());
      await SessionService.setEmail(_email.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    final userId = await SessionService.getUserId();
    if (userId == null) return;

    final photoUrl = await PhotoApi.uploadPhoto(userId, _selectedImage!);

    setState(() => _isUploading = false);

    if (photoUrl != null) {
      await SessionService.savePhotoUrl(photoUrl);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo uploaded successfully")),
      );
    } else {
      Navigator.pop(context, false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeletePhoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Photo"),
          content: const Text("Are you sure you want to delete your photo?"),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // ❗ pakai dialogContext
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                ); // ❗ hindari pakai context global di sini

                final userId = await SessionService.getUserId();
                if (userId == null || !mounted) return;

                setState(() => _isUploading = true);
                bool success = await PhotoApi.deletePhoto(userId);
                if (!mounted) return;

                setState(() => _isUploading = false);

                if (success) {
                  setState(() {
                    _selectedImage = null;
                    _currentPhotoUrl = null;
                  });
                  await SessionService.savePhotoUrl('');

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Photo deleted successfully"),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to delete photo"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _profileForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          const SizedBox(height: 10),
          Center(
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.file(
                      _selectedImage!,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  )
                : (_currentPhotoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Image.network(
                            _currentPhotoUrl!,
                            key: ValueKey(_currentPhotoUrl),
                            headers: const {'Cache-Control': 'no-cache'},
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 50),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        )),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              fixedSize: Size(150, 50),
            ),
            icon: const Icon(Icons.photo),
            label: const Text(
              "Select Photo",
              style: TextStyle(color: const Color.fromARGB(255, 45, 93, 141)),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: (_selectedImage != null || _currentPhotoUrl != null)
                ? () => _confirmDeletePhoto(context)
                : null,
            icon: Icon(Icons.delete),
            label: Text("Delete Photo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              fixedSize: Size(150, 50),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey, thickness: 3, indent: 16, endIndent: 16),
          const SizedBox(height: 20),
          TextFormField(
            controller: _username,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter username' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter email' : null,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(
              labelText: 'New Password (leave blank to keep current)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey, thickness: 3, indent: 16, endIndent: 16),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isUploading ? null : () => _updateProfile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 45, 93, 141),
              fixedSize: Size(150, 50),
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Upload Photo & Update Profile",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: _isDataLoaded
            ? _profileForm(context)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
