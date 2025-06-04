import 'package:flutter/material.dart';
import 'package:studybuddy/models/user.dart';
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

  Future<void> _updateProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await ProfileApi.updateUser(
        username: _username.text.trim().isNotEmpty ? _username.text.trim() : null,
        email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
        password: _password.text.trim().isNotEmpty ? _password.text.trim() : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on Map<String, dynamic> catch (errors) {
      errors.forEach((field, msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field: $msg'), backgroundColor: Colors.red),
        );
      });
    } on String catch (msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error: $msg'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _profileForm(
    BuildContext context,
    TextEditingController _username,
    TextEditingController _email,
    TextEditingController _password,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          Center(
            child: Text(
              'Profile Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _username,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator:
                (val) => val == null || val.isEmpty ? 'Enter username' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator:
                (val) => val == null || val.isEmpty ? 'Enter email' : null,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'New Password (leave blank to keep current)',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _updateProfile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 45, 93, 141),
              fixedSize: Size.fromHeight(45),
            ),
            child: const Text(
              'Update Profile',
              style: TextStyle(color: Colors.white),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<UserModel?>(
          future: ProfileApi.getUserById(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              if (!_isDataLoaded) {
                _username.text = snapshot.data!.username;
                _email.text = snapshot.data!.email;
                _isDataLoaded = true;
              }
              return _profileForm(context, _username, _email, _password);
            } else {
              return const Center(child: Text("Failed to load user data"));
            }
          },
        ),
      ),
    );
  }
}
