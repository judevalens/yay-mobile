import 'package:flutter/material.dart';
import 'package:yay/screens%20v2/feed/feed.dart';
import 'package:yay/screens%20v2/me/me.dart';
import 'package:yay/screens%20v2/player/Player.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  Player _playerPage = Player();
  Feed _feed = Feed();
  Me _me = Me();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        sizing: StackFit.expand,
        index: currentIndex,
        children: [_feed, _playerPage, _me],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(width: 0.2, style: BorderStyle.solid, color: Colors.grey),
        )),
        child: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              print("taped!!");
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.music_note_sharp), label: "Music"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: "Me"),
          ],
        ),
      ),
    );
  }
}
