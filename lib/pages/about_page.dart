import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cara Penggunaan StudyBuddy+',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Login menggunakan akun kamu dengan password yang sudah terenkripsi.\n\n'
                    '2. Atur jadwal belajar dan buat catatan penting di halaman Profil.\n\n'
                    '3. Gunakan fitur Saran & Kesan untuk memberi feedback tentang aplikasi.\n\n'
                    '4. Aktifkan mode fokus untuk membantu menjaga konsentrasi saat belajar.\n\n'
                    '5. Gunakan fitur konversi waktu dan mata uang saat kamu belajar di lokasi berbeda.\n\n'
                    '6. Jangan lupa logout setelah selesai menggunakan aplikasi.\n\n'
                    'Terima kasih sudah menggunakan StudyBuddy+! Semoga membantu kamu belajar lebih efektif.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}