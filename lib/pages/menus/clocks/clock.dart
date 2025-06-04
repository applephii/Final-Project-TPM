import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late Timer _timer;
  String wib = '';
  String london = '';

  void _updateTime() {
    final now = DateTime.now();
    final wibTime = now.toUtc().add(const Duration(hours: 7)); // UCT+7
    final londonTime = now.toUtc().add(const Duration(hours: 1)); //UCT+1

    setState(() {
      wib = DateFormat('HH:mm').format(wibTime);
      london = DateFormat('HH:mm').format(londonTime);
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
    return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      //jam wib
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "WIB",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 229, 229, 229),
            ),
          ),
          // const SizedBox(height: 2),
          Text(
            wib,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),

      const SizedBox(width: 40),

      //jam london
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "London",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 229, 229, 229),
            ),
          ),
          // const SizedBox(height: 2),
          Text(
            london,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    ],
  );
  }
}