import 'package:flutter/material.dart';
import 'package:yay/screens%20v2/feed/feed.dart';
import 'package:yay/screens%20v2/me/me.dart';
import 'package:yay/screens%20v2/player/player.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Feed() /*IndexedStack(
        children: [Feed(), Player(), Me()],
      )*/,
      bottomNavigationBar: BottomNavigationBar(
        items: [BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: "Home"),BottomNavigationBarItem(icon: Icon(Icons.music_note_sharp), label: "Music"),BottomNavigationBarItem(icon: Icon(Icons.person_outlined),label: "Me"),],
      ),
    );
  }
}
