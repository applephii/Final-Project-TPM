import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeconvertPage extends StatefulWidget {
  const TimeconvertPage({super.key});

  @override
  State<TimeconvertPage> createState() => _TimeconvertPageState();
}

class _TimeconvertPageState extends State<TimeconvertPage> {
  late Timer _timer;
  String wib = '';
  String london = '';
  String wit = '';
  String wita = '';
  String bangkok = '';
  String tokyo = '';
  String seoul = '';

  int wibOffset = 7;
  int londonOffset = 1;
  int witOffset = 9;
  int witaOffset = 8;
  int bangkokOffset = 7;
  int tokyoOffset = 9;
  int seoulOffset = 9;

  String diff(int zoneOffset) {
    int diffHours = zoneOffset - wibOffset;
    if (diffHours == 0) return 'Same time as WIB';
    if (diffHours > 0) return '$diffHours hour(s) ahead of WIB';
    return '${-diffHours} hour(s) behind WIB';
  }

  void _updateTime() {
    final now = DateTime.now();
    final wibTime = now.toUtc().add(const Duration(hours: 7)); // UCT+7
    final londonTime = now.toUtc().add(const Duration(hours: 1)); //UCT+1
    final witTime = now.toUtc().add(const Duration(hours: 9)); // UCT+9
    final witaTime = now.toUtc().add(const Duration(hours: 8)); // UCT+8
    final bangkokTime = now.toUtc().add(const Duration(hours: 7)); // UCT+7
    final tokyoTime = now.toUtc().add(const Duration(hours: 9)); // UCT+9
    final seoulTime = now.toUtc().add(const Duration(hours: 9)); // UCT+9

    setState(() {
      wib = DateFormat('HH:mm').format(wibTime);
      london = DateFormat('HH:mm').format(londonTime);
      wit = DateFormat('HH:mm').format(witTime);
      wita = DateFormat('HH:mm').format(witaTime);
      bangkok = DateFormat('HH:mm').format(bangkokTime);
      tokyo = DateFormat('HH:mm').format(tokyoTime);
      seoul = DateFormat('HH:mm').format(seoulTime);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'What Time Is It In...',
          style: TextStyle(color: Color.fromARGB(255, 45, 93, 141)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              timeRow('WIB', 'GMT+7', wib, diff(wibOffset)),
              const SizedBox(height: 12),
              timeRow('WIT', 'GMT+9', wit, diff(witOffset)),
              const SizedBox(height: 12),
              timeRow('WITA', 'GMT+8', wita, diff(witaOffset)),
              const SizedBox(height: 12),
              timeRow('London', 'GMT+1', london, diff(londonOffset)),
              const SizedBox(height: 12),
              timeRow('Bangkok', 'GMT+7', bangkok, diff(bangkokOffset)),
              const SizedBox(height: 12),
              timeRow('Tokyo', 'GMT+9', tokyo, diff(tokyoOffset)),
              const SizedBox(height: 12),
              timeRow('Seoul', 'GMT+9', seoul, diff(seoulOffset)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget timeRow(String place, String gmt, String time, String differenceText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(255, 45, 93, 141),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              Text(
                gmt,
                style: const TextStyle(
                  color: Color.fromARGB(255, 222, 222, 222),
                  fontSize: 16,
                ),
              ),
              Text(
                differenceText,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 222, 222, 222),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}
