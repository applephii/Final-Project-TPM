import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:studybuddy/sevices/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studybuddy/sevices/notification_service.dart';

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

  Duration _duration = Duration.zero;
  Duration _remaining = Duration.zero;

  Timer? _timer;
  bool _isRunning = false;
  bool _soundOn = true;
  bool _notifOn = true;

  final _player = AudioPlayer();
  final _notifPlugin = flutterLocalNotificationsPlugin;
  final String _alarmUrl =
      'https://www.orangefreesounds.com/wp-content/uploads/2018/12/Gentle-wake-alarm-clock.mp3';

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

    Duration _duration = Duration.zero;
    Duration _remaining = Duration.zero;

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
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  //Timer
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'repeat_channel_id',
          'Repeating Notifications',
          channelDescription: 'Notifications shown periodically',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Study session is done!',
      'Remember to take a short break <3',
      platformDetails,
    );
  }

  Future<void> _playAlarm() async {
    await _player.play(UrlSource(_alarmUrl));
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = _duration;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining.inSeconds <= 0) {
          _remaining = Duration.zero;
          _isRunning = false;
          timer.cancel();
          if (_soundOn) _playAlarm();
          if (_notifOn) _showNotification();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _duration;
    });
  }

  String _formatDuration(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0");

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
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              decoration: BoxDecoration(
                color: _isMoving ? Colors.blue.shade700 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        _isMoving
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
                  Icon(Icons.directions_run, size: 32, color: Colors.white),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Text(
                      _isMoving
                          ? 'Device bergerak pada $formattedLastMovement'
                          : 'Tidak ada pergerakan terdeteksi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Study Timer",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const Text(
                  'Set Your Study Session',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showDurationPickerDialog(),
                  child: Text(
                    _formatDuration(_remaining),
                    style: const TextStyle(fontSize: 55),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRunning
                            ? Colors.red
                            : const Color.fromARGB(255, 45, 93, 141),
                    fixedSize: Size(150, 50),
                  ),
                  child: Text(
                    _isRunning ? 'Stop' : 'Start',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                SwitchListTile(
                  title: const Text('Suara'),
                  value: _soundOn,
                  onChanged: (val) => setState(() => _soundOn = val),
                ),
                SwitchListTile(
                  title: const Text('Notifikasi'),
                  value: _notifOn,
                  onChanged: (val) => setState(() => _notifOn = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerColumn(
    String label,
    int value,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        SizedBox(
          height: 100,
          width: 60,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 30,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.005,
            diameterRatio: 1.2,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder:
                  (context, index) => Center(
                    child: Text('$index', style: TextStyle(fontSize: 14)),
                  ),
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }

  void _showDurationPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int hours = _duration.inHours;
        int minutes = _duration.inMinutes % 60;
        int seconds = _duration.inSeconds % 60;

        return AlertDialog(
          title: const Text('Set Timer'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerColumn("Hrs", hours, 23, (val) => hours = val),
              _buildPickerColumn("Min", minutes, 59, (val) => minutes = val),
              _buildPickerColumn("Sec", seconds, 59, (val) => seconds = val),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _duration = Duration(
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  );
                  _remaining = _duration;
                });
                Navigator.pop(context);
              },
              child: const Text('Set', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}
