import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studybuddy/pages/home_page.dart';
import 'package:studybuddy/pages/login_page.dart';
import 'package:studybuddy/pages/menus/buddies_page.dart';
import 'package:studybuddy/pages/menus/clocks/timeConvert_page.dart';
import 'package:studybuddy/pages/menus/mainMenu_page.dart';
import 'package:studybuddy/pages/menus/moneyConvert_page.dart';
import 'package:studybuddy/pages/menus/place/placeList_page.dart';
import 'package:studybuddy/pages/menus/studybuddy_page.dart';
import 'package:studybuddy/pages/menus/task/taskList_page.dart';
import 'package:studybuddy/pages/profile_page.dart';
import 'package:studybuddy/pages/regist_page.dart';
import 'package:studybuddy/sevices/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await initNotifications();
  await requestNotificationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 45, 93, 141)),
      ),
      // home: HomePage(),
      initialRoute: '/login',
      routes: {
        '/home': (context) => HomePage(),
        '/mainmenu': (context) => MainmenuPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistPage(),
        '/timeconverter': (context) => const TimeconvertPage(),
        '/moneyconverter': (context) => const MoneyconvertPage(),
        '/placeList': (context) => const PlacelistPage(),
        '/profile': (context) => const ProfilePage(),
        '/tasklist': (context) => const TasklistPage(),
        '/studybuddy': (context) => const StudybuddyPage(),
        '/buddies': (context) => const StudyBuddiesTimePage()
      },
    );
  }
}