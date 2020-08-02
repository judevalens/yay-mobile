import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/homePage/room_page.dart';
import 'package:yay/screens/player/Player.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

enum ScreenType { Player, Room }

class HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('yay.homepage/initSpotify');

  HomePageState() {
    print("creates homePage\n");
  }

  @override

    super.initState();
    SpotifyApi.getSpotifyAPI().connect();
  }

  int _currentPageIndex = 0;
  List<ScreenType> screenTypes = <ScreenType>[
    ScreenType.Player,
    ScreenType.Room,
  ];

  Widget getScreen(ScreenType st, BuildContext context) {
    Widget w;
    switch (st) {
      case ScreenType.Player:
        w = ChangeNotifierProvider(
          create: (context) => SpotifyApi.getSpotifyAPI(),
          child: PlayerPage(),
        );
        break;
      case ScreenType.Room:
        w = ChangeNotifierProvider(
          create: (context) => SpotifyApi.getSpotifyAPI(),
          child: RoomPage(),
        );
        break;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("yay"),
      ),
      body: getScreen(screenTypes[_currentPageIndex], context),
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
