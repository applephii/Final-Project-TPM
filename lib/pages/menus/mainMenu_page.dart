import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:studybuddy/pages/menus/clocks/clock.dart';
import 'package:studybuddy/sevices/notification_service.dart';
import 'package:studybuddy/sevices/session.dart';

class MainmenuPage extends StatefulWidget {
  const MainmenuPage({super.key});

  @override
  State<MainmenuPage> createState() => _MainmenuPageState();
}

class _MainmenuPageState extends State<MainmenuPage> {
  String _username = 'Guest';
  bool _isNotificationOn = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadusername();
  }

  Future<void> _loadusername() async {
    final username = await SessionService.getUsername();

    setState(() {
      _username = username ?? 'Guest';
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StaggeredGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            StaggeredGridTile.fit(
              crossAxisCellCount: 3,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: _headerRow(),
              ),
            ),

            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/timeconverter');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 62, 128, 194),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Clock()],
                ),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/placeList');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 132, 181, 229),
                ),
                child: Icon(
                  Icons.map,
                  size: 70,
                  color: Color.fromARGB(255, 45, 93, 141),
                ),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/buddies');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 193, 218, 244),
                ),
                child: Text("StudyBuddy", style: TextStyle(fontSize: 30)),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/moneyconverter');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                ),
                child: Icon(
                  Icons.monetization_on_sharp,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/studybuddy');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Icon(
                  Icons.more_horiz_outlined,
                  size: 50,
                  color: Color.fromARGB(255, 45, 93, 141),
                ),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/tasklist');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color.fromARGB(255, 142, 179, 215),
                ),
                child: Text(
                  "Tasks",
                  style: TextStyle(fontSize: 30, color: Colors.white, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Hello, $_username!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Switch(
          value: _isNotificationOn,
          onChanged: (value) async {
            setState(() => _isNotificationOn = value);
            if (value) {
              await showRepeatingNotification();
            } else {
              await cancelNotification();
            }
          },
        ),
      ],
    );
  }
}
