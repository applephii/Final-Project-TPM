import 'package:flutter/material.dart';
import 'package:studybuddy/sevices/profile_api.dart';
import 'package:studybuddy/sevices/session.dart';

class ProfilemenuPage extends StatefulWidget {
  const ProfilemenuPage({super.key});

  @override
  State<ProfilemenuPage> createState() => _ProfilemenuPageState();
}

class _ProfilemenuPageState extends State<ProfilemenuPage> {
  String _username = '';
  String _email = '';
  bool _isLoaded = false;
  bool _hasPhoto = false;

  @override
  void initState() {
    super.initState();
    _loaduser();
  }

  Future<void> _loaduser() async {
    final username = await SessionService.getUsername();
    final email = await SessionService.getEmail();

    setState(() {
      _username = username ?? 'Guest';
      _email = email ?? 'guest@gmail.com';
      _isLoaded = true;
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your profile?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await ProfileApi.deleteUser();
      if (success) {
        await SessionService.clearUser();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child:
            !_isLoaded
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _profile(),
                ),
      ),
    );
  }

  Widget _profile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              _hasPhoto
                                  ? const AssetImage(
                                    'assets/images/profile.png',
                                  )
                                  : const NetworkImage(
                                    'https://cdn-icons-png.flaticon.com/512/3736/3736502.png',
                                  ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Handle profile edit
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Edit profile tapped"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _username,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 45, 93, 141),
              fixedSize: Size(300, 50),
            ),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/profile');
              if (result == true) {
                _loaduser();
              }
            },
            child: Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _confirmDelete(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              fixedSize: Size(300, 50),
            ),
            child: Text(
              'Delete Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              fixedSize: Size(300, 50),
            ),
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await SessionService.clearUser();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
