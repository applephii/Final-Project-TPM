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

  //placeholder buddies
  final List<Map<String, String>> friends = [
    {'name': 'Harry', 'location': 'London'},
    {'name': 'Seungmin', 'location': 'Seoul'},
    {'name': 'Yuuji', 'location': 'Tokyo'},
    {'name': 'Qi', 'location': 'Yogyakarta'},
  ];

  //placeholder for books
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

    _subscription = accelerometerEventStream().listen((event) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _content()),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBookCard(Map<String, String> book) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined, color: Color.fromARGB(255, 45, 93, 141), size: 40,),
        title: Text(book['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white
          ),
          onPressed: () async {
            final url = Uri.parse(book['link']!);
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch ${book['link']}')),
              );
            }
          },
          child: const Text("Open Book"),
        ),
      ),
    );
  }

  Widget _content() {
    return ListView(
      children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Study Device Movement Tracker",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: _isMoving ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run,
                    color: _isMoving ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isMoving
                        ? 'Device bergerak pada $formattedLastMovement'
                        : 'Tidak ada pergerakan',
                    style: TextStyle(
                      color: _isMoving ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),
          Text(
            "Study Buddies",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    color: const Color.fromARGB(255, 45, 93, 141),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            friend['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            friend['location'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Books Available",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...books.map((book) => _buildBookCard(book)).toList(),
        ],
      ),
      ]
    );
  }
}
