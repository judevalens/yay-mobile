import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/home_screen//room_page.dart';
import 'package:yay/screens/player/Player.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  Socket socket;
  SharedPreferences sharedPreferences;
   HomePage (this.socket);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState(socket);
  }
}

enum ScreenType { Player, Room }

class HomePageState extends State<HomePage> {
  Socket socket;
  Widget mainPage;
  Widget loginPage;
  static const platform = const MethodChannel('yay.homepage/spotify');

  HomePageState(this.socket) {
    print("creates homePage\n");
  }

  @override
  void initState() {
    super.initState();

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
        w = ChangeNotifierProvider.value(
          value: SpotifyApi.getSpotifyAPI(),
          child: PlayerPage(),
        );
        break;
      case ScreenType.Room:
        w = ChangeNotifierProvider.value(
          value: SpotifyApi.getSpotifyAPI(),
          child: RoomPage(),
        );
        break;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
