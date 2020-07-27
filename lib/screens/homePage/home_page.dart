import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay/screens/homePage/room_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('yay.homepage/initSpotify');
  HomePageState() {
    print("creates homePage\n");
  }
  @override
  void initState() {
    super.initState();
    Future<String> result = platform.invokeMethod('connect');

    result.then((value) {
      print("result from Spotify : $value\n");
    });
  }

  int _currentPageIndex = 0;
  List<Widget> pages = <Widget>[Text("hello"), RoomPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("yay"),
      ),
      body: pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            title: Text("Rooms"),
          ),
        ],
        onTap: (currentPageIndex) {
          setState(() {
            _currentPageIndex = currentPageIndex;
          });
        },
      ),
    );
  }
}
