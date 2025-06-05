import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class StudybuddyPage extends StatefulWidget {
  const StudybuddyPage({super.key});

  @override
  State<StudybuddyPage> createState() => _StudybuddyPageState();
}

class _StudybuddyPageState extends State<StudybuddyPage> {
  double _prevX = 0, _prevY = 0, _prevZ = 0;
  DateTime _lastMovementTime = DateTime.now();
  late StreamSubscription _subscription;
  static const double movementThreshold = 0.2;
  bool _isMoving = false;
  Timer? _movementResetTimer;

  final List<Map<String, String>> books = [
    {
      'name': 'Book 1',
      'link':
          'https://www.google.co.id/books/edition/Pengantar_Teknik_Informatika/b7JbEQAAQBAJ?hl=en&gbpv=0',
    },
    {
      'name': 'Book 2',
      'link':
          'https://www.google.co.id/books/edition/FILSAFAT_INFORMATIKA/C_Q6EQAAQBAJ?hl=en&gbpv=0',
    },
    {
      'name': 'Book 3',
      'link':
          'https://www.google.co.id/books/edition/LOGIKA_INFORMATIKA/nkSwEAAAQBAJ?hl=en&gbpv=0',
    },
    {
      'name': 'Book 4',
      'link':
          'https://www.google.co.id/books/edition/Teknologi_Informatika/lE3OEAAAQBAJ?hl=en&gbpv=0',
    },
  ];

  String get formattedLastMovement =>
      DateFormat('HH:mm:ss').format(_lastMovementTime);

  void _registerMovement() {
    setState(() {
      _isMoving = true;
      _lastMovementTime = DateTime.now();
    });

    _movementResetTimer?.cancel();
    _movementResetTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isMoving = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _subscription = accelerometerEvents.listen((event) {
      final deltaX = (event.x - _prevX).abs();
      final deltaY = (event.y - _prevY).abs();
      final deltaZ = (event.z - _prevZ).abs();

      if (deltaX > movementThreshold ||
          deltaY > movementThreshold ||
          deltaZ > movementThreshold) {
        debugPrint("MOTION DETECTED");
        _registerMovement();
      }

      _prevX = event.x;
      _prevY = event.y;
      _prevZ = event.z;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _movementResetTimer?.cancel();
    super.dispose();
  }

  Widget _buildBookCard(Map<String, String> book) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      shadowColor: Colors.blue.shade200,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: Icon(Icons.menu_book_outlined,
            color: Colors.blue.shade800, size: 40),
        title: Text(
          book['name'] ?? '',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            final url = Uri.parse(book['link']!);
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch ${book['link']}')),
              );
            }
          },
          child: const Text(
            "Open",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Device Movement Tracker",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              decoration: BoxDecoration(
                color: _isMoving ? Colors.blue.shade700 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _isMoving
                        ? Colors.blue.shade300.withOpacity(0.7)
                        : Colors.grey.shade500.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Text(
                      _isMoving
                          ? 'Device bergerak pada $formattedLastMovement'
                          : 'Tidak ada pergerakan terdeteksi',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Books Available",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            ...books.map((book) => _buildBookCard(book)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
