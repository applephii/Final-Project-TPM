import 'package:flutter/material.dart';
import 'package:studybuddy/pages/about_page.dart';
import 'package:studybuddy/pages/kesanPesan_page.dart';
import 'package:studybuddy/pages/menus/mainMenu_page.dart';
import 'package:studybuddy/pages/profileMenu_page.dart';
import 'package:studybuddy/sevices/session.dart';
import 'package:studybuddy/widgets/navbottom.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [MainmenuPage(), ProfilemenuPage(), KesanpesanPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StudyBuddy', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      backgroundColor: Colors.white,
    );
  }

  
}
