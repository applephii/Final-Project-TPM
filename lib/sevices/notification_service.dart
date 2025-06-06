import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'repeat_channel_id',
    'Repeating Notifications',
    description: 'Notifications shown periodically',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}


Future<void> requestNotificationPermission() async {
  if (Platform.isIOS) {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    if (granted == true) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();

  }
}

Future<void> showRepeatingNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'repeat_channel_id',
    'Repeating Notifications',
    channelDescription: 'Notifications shown periodically',
    importance: Importance.max,
    priority: Priority.high,
  );

  const platformDetails = NotificationDetails(android: androidPlatformChannelSpecifics);
  //notif langsung
  await flutterLocalNotificationsPlugin.show(
    0,
    'Word of the Moment',
    'Keep going! You\'re doing great!',
    platformDetails,
  );

  await flutterLocalNotificationsPlugin.periodicallyShow(
    1,
    'Word of the Moment',
    'Keep going! You\'re doing great!',
    RepeatInterval.everyMinute,
    platformDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 🔥 NEW REQUIRED PARAM
  );
}

Future<void> cancelNotification() async {
  await flutterLocalNotificationsPlugin.cancel(0);
  await flutterLocalNotificationsPlugin.cancel(1);
}