import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/login_screen/login_screen.dart';
import 'package:yay/screens/rooms_screen/room_page.dart';
import 'package:yay/screens/player/Player.dart';
import 'package:provider/provider.dart';
import 'package:yay/screens/setting_screen/setting_screen.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  SharedPreferences sharedPreferences;

  HomePage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

enum ScreenType { Player, Room }

class HomePageState extends State<HomePage> {
  Widget mainPage;
  Widget loginPage;
  Map<ScreenType, Widget> _screens = Map();

  HomePageState() {
    print("creates homePage\n");
  }

  @override
  void initState() {
    super.initState();
    _screens[ScreenType.Player] = ChangeNotifierProvider.value(
      value: App.getInstance().playBackController.currentPlayBackState,
      child: PlayerPage(),
    );

    _screens[ScreenType.Room] = ChangeNotifierProvider.value(
      value: App.getInstance().nt,
      child: RoomListPage(App.getInstance().roomController),
    );
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
          value: App.spotifyApi,
          child: PlayerPage(),
        );
        break;
      case ScreenType.Room:
        w = ChangeNotifierProvider.value(
          value: App.getInstance().nt,
          child: RoomListPage(App.getInstance().roomController),
        );
        break;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Authorization, bool>(
      selector: (_, authorization) => authorization.isAuthorized(),
      builder: (context, isAuthorized, _) {
        return isAuthorized ? buildHomePage() : LoginScreen();
      },
    );
  }

  FloatingActionButton getFloatingButton(BuildContext context) {
    FloatingActionButton w;
    if (screenTypes[_currentPageIndex] == ScreenType.Room) {
      w = FloatingActionButton(
        onPressed: () {
          addRoomModalSheet(context);
        },
        focusColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColorDark,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      );
    }

    return w;
  }

  Future<void> addRoomModalSheet(BuildContext context) {
    String joinCode;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1,
          widthFactor: 0.5,
          child: Container(
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Add/Join a room",
                    style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20)),
                Divider(
                  thickness: 2,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Enter Join Code"),
                  onChanged: (code){
                    joinCode = code;
                  },
                ),
                Container(
                    width: double.infinity,
                    child: ElevatedButton(

                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).accentColor)),
                      onPressed: () {
                        App.getInstance().roomController.joinRoom(joinCode);
                      },
                      child: Text("Join room"),
                    )),
                Divider(
                  thickness: 2,

                ),
                Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).accentColor)),
                      onPressed: () {
                        App.getInstance().roomController.createRoom();
                      },
                      child: Text("Create room"),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget joinRoomExpandable() {
    return Container();
  }

  Widget buildHomePage() {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text("yay"),
          actions: [
            IconButton(
                icon: new Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Setting();
                  }));
                })
          ],
        ),
        body: IndexedStack(
          index: _currentPageIndex,
          children: [
            ChangeNotifierProvider.value(
              value: App.getInstance().playBackController.currentPlayBackState,
              child: PlayerPage(),
            ),
            RoomListPage(App.getInstance().roomController),
          ],
        ),
        floatingActionButton: getFloatingButton(context),
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
      ),
    );
  }
}
