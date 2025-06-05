import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudyBuddiesTimePage extends StatefulWidget {
  const StudyBuddiesTimePage({super.key});

  @override
  State<StudyBuddiesTimePage> createState() => _StudyBuddiesTimePageState();
}

class _StudyBuddiesTimePageState extends State<StudyBuddiesTimePage> {
  late Timer _timer;

  // Daftar teman dengan nama dan timezone offset default (misal zona waktu asal teman)
  final List<Map<String, dynamic>> friends = [
    {'name': 'Harry', 'zoneOffset': 0}, // misal GMT+0 untuk demo
    {'name': 'Seungmin', 'zoneOffset': 9},
    {'name': 'Yuuji', 'zoneOffset': 9},
    {'name': 'Qi', 'zoneOffset': 7},
  ];

  // Daftar timezone pilihan dengan label dan offset dari UTC
  final List<Map<String, dynamic>> timeZones = [
    {'label': 'WIB (GMT+7)', 'offset': 7},
    {'label': 'London (GMT+1)', 'offset': 1},
    {'label': 'WIT (GMT+9)', 'offset': 9},
    {'label': 'WITA (GMT+8)', 'offset': 8},
    {'label': 'Bangkok (GMT+7)', 'offset': 7},
    {'label': 'Tokyo (GMT+9)', 'offset': 9},
    {'label': 'Seoul (GMT+9)', 'offset': 9},
  ];

  Map<String, int> selectedOffsets = {};
  Map<String, String> selectedLabels = {};

  @override
  void initState() {
    super.initState();

    // Initialize dropdown timezone default per friend using first matching timezone label for the offset
    for (var friend in friends) {
      final name = friend['name'] as String;
      final offset = friend['zoneOffset'] as int;

      final matchingTimeZone = timeZones.firstWhere(
        (tz) => tz['offset'] == offset,
        orElse: () => timeZones[0], // fallback if none found
      );

      selectedOffsets[name] = matchingTimeZone['offset'] as int;
      selectedLabels[name] = matchingTimeZone['label'] as String;
    }

    // Update time every second to refresh UI
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String convertTime(int sourceOffset, int targetOffset) {
    final now = DateTime.now().toUtc();
    final sourceTime = now.add(Duration(hours: sourceOffset));
    final convertedTime = sourceTime.add(Duration(hours: targetOffset - sourceOffset));
    return DateFormat('HH:mm').format(convertedTime);
  }

  String diffText(int sourceOffset, int targetOffset) {
    final diffHours = targetOffset - sourceOffset;
    if (diffHours == 0) return 'Same time zone';
    if (diffHours > 0) return '$diffHours hour(s) ahead';
    return '${-diffHours} hour(s) behind';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Buddies', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final friendName = friend['name'] as String;
          final friendSourceOffset = friend['zoneOffset'] as int;
          final selectedLabel = selectedLabels[friendName];
          final selectedOffset = selectedOffsets[friendName] ?? friendSourceOffset;

          final originalTime = convertTime(friendSourceOffset, friendSourceOffset);
          final convertedTime = convertTime(friendSourceOffset, selectedOffset);
          final difference = diffText(friendSourceOffset, selectedOffset);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Original Time (${friendSourceOffset >= 0 ? 'GMT+${friendSourceOffset}' : 'GMT${friendSourceOffset}'}): $originalTime'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Convert to: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: selectedLabel != null && timeZones.any((tz) => tz['label'] == selectedLabel)
                            ? selectedLabel
                            : timeZones[0]['label'] as String,
                        items: timeZones.map((tz) {
                          return DropdownMenuItem<String>(
                            value: tz['label'] as String,
                            child: Text(tz['label'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedLabels[friendName] = value;
                            selectedOffsets[friendName] = timeZones.firstWhere(
                              (tz) => tz['label'] == value,
                            )['offset'] as int;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Converted Time: $convertedTime'),
                  Text(
                    difference,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}
