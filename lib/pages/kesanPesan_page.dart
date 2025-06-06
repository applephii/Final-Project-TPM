import 'package:flutter/material.dart';

class KesanpesanPage extends StatelessWidget {
  const KesanpesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About StudyBuddy', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/images/profile.png'), // pastikan ada file ini di folder assets
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'R.A. Kurnia Haqiki\n123220022',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Center(
                        child: Text(
                          'Kesan & Pesan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Ya, stress dikit',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}