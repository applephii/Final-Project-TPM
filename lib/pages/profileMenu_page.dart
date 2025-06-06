import 'package:flutter/material.dart';
import 'package:studybuddy/pages/profile_page.dart';
import 'package:studybuddy/sevices/photo_api.dart';
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
  String? _photoUrl;
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
    final userId = await SessionService.getUserId();

    print('UserId from session: $userId');

    String? photoUrl;

    if (userId != null) {
      final photoData = await PhotoApi.getProfilePhotoUrl(userId);

      if (photoData != null) {
        // photoUrl = photoData['url'];
        photoUrl = photoData;
        // final updatedAt = photoData['updatedAt'];

        print('Photo URL from API: $photoUrl');
        // print('Photo updatedAt from API: $updatedAt');

        // await SessionService.savePhotoUrl(photoUrl ?? '', updatedAt ?? '');
        await SessionService.savePhotoUrl(photoUrl ?? '');
      } else {
        // await SessionService.savePhotoUrl('', '');
        await SessionService.savePhotoUrl('');
        // photoUrl = '';
      }
    } else {
      print('UserId is null, cannot fetch photo URL.');
    }

    setState(() {
      _username = username ?? 'Guest';
      _email = email ?? 'guest@gmail.com';
      _photoUrl = photoUrl;
      _hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
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
                          // backgroundImage:
                          // _hasPhoto
                          //     ? NetworkImage(_photoUrl!)
                          //     : NetworkImage(
                          //       'https://cdn-icons-png.flaticon.com/512/3736/3736502.png',
                          //     ),
                          // NetworkImage(
                          //   _hasPhoto
                          //       ? _photoUrl!
                          //       : 'https://cdn-icons-png.flaticon.com/512/3736/3736502.png',
                          // ),
                          // child: ClipOval(
                          //   child: FadeInImage.assetNetwork(
                          //     placeholder:
                          //         'https://cdn-icons-png.flaticon.com/512/3736/3736502.png',
                          //     image: _photoUrl!,
                          //     fit: BoxFit.cover,
                          //     height: 160,
                          //     width: 160,
                          //   ),
                          // ),
                          child: _childPhotoWidget(),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ).then((shouldReload) {
                if (shouldReload == true) {
                  _loaduser();
                }
              });
            },
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 16, color: Colors.white),
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
          SizedBox(height: 15),
          Container(
            height: 2,
            width: double.infinity,
            color: const Color.fromARGB(255, 45, 93, 141),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 45, 93, 141),
              fixedSize: Size(300, 50),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/kesan');
            },
            child: const Text(
              'About',
              style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _childPhotoWidget() {
    const placeholderUrl =
        'https://cdn-icons-png.flaticon.com/512/3736/3736502.png';

    return CircleAvatar(
      radius: 80,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          _hasPhoto && _photoUrl != null && _photoUrl!.isNotEmpty
              ? _photoUrl!
              : placeholderUrl,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              placeholderUrl,
              width: 160,
              height: 160,
              fit: BoxFit.cover,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
