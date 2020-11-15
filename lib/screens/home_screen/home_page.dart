import 'package:flutter/cupertino.dart';
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

  double statusBArHeight;
  double navigationBArHeight;

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
        return isAuthorized ? buildHomePage(context) : LoginScreen();
      },
    );
  }

  Widget buildHomePage(BuildContext _context) {
    statusBArHeight = MediaQuery.of(context).padding.top;
    navigationBArHeight = MediaQuery.of(context).padding.bottom;
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
                  Icons.search_sharp,
                  color: Colors.white,
                ),
                color: Colors.white,
                onPressed: () {
                  searchModalSheet(_context);
                }),
            IconButton(
                icon: new Icon(
                  Icons.my_library_music_sharp,
                  color: Colors.white,
                ),
                color: Colors.white,
                onPressed: () {
                  playListModalSheet(_context);
                }),
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
    String joinCode = "";
    String roomName = "";
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
                  onChanged: (code) {
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
                TextField(
                  decoration: InputDecoration(labelText: "Enter Join Code"),
                  onChanged: (name) {
                    roomName = name;
                  },
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Theme.of(context).accentColor)),
                    onPressed: () {
                      App.getInstance().roomController.createRoom(roomName);
                    },
                    child: Text("Create room"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> searchModalSheet(BuildContext _context) {
    String joinCode = "";
    String roomName = "";
    return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (BuildContext context) {
          return searchPage();
        });
  }

  Future<void> playListModalSheet(BuildContext _context) {
    String joinCode = "";
    String roomName = "";
    return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (BuildContext context) {
          return playList(context);
        });
  }

  Widget joinRoomExpandable() {
    return Container();
  }

  Widget searchPage() {
    return Container(
      height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - statusBArHeight,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded), onPressed: null),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Search",
                  style: Theme.of(context).accentTextTheme.headline4,
                ),
              ),
            ],
          ),
          Divider(),
          searchBar(),
          Divider(),
          Expanded(
            child: resultContainer(),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                decoration: InputDecoration(hintText: "Search for a song "),
                onChanged: (text) {
                  App.getInstance().browserController.search(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultContainer() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: searchResultList(context),
    );
  }

  Widget playList(BuildContext context) {
    print("appbar " + AppBar().preferredSize.height.toString());
    print("appbar " + statusBArHeight.toString());
    print("appbar " + navigationBArHeight.toString());
    print("appbar " + MediaQuery.of(context).viewInsets.bottom.toString());
    return Container(
      height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - statusBArHeight,
      padding: EdgeInsets.only(
        top: statusBArHeight,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: [
            IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded), onPressed: null),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Playlists",
                style: Theme.of(context).accentTextTheme.headline4,
              ),
            ),
          ],
        ),
        Divider(),
        Expanded(child: new ListView()),
      ]),
    );
  }

  Widget searchResultList(BuildContext context) {
    return StreamBuilder(
        stream: App.getInstance().browserController.queryResponseStreamController.stream,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> responses) {
          Widget w;

          if (responses.hasData) {
            List<Widget> responseItems = new List();

            responses.data.forEach((element) {
              responseItems.add(getSearchQueryItem(element));
            });

            w = ListView(
              children: responseItems,
            );
          } else {
            w = Text("No result yet");
          }

          return w;
        });
  }

  Widget getSearchQueryItem(Map<String, dynamic> track) {
    var imagesListLength = track["album"]["images"].length;
    String artistList = "";
    int counter = 0;
    for (var value in track["artists"]) {
      artistList += value["name"];

      counter++;

      if (counter < track["artists"].length) {
        artistList += ", ";
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: Image.network(track["album"]["images"][1]["url"]),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  track["name"],
                  style: Theme.of(context).accentTextTheme.button,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artistList,
                  style: Theme.of(context).accentTextTheme.bodyText2,
                  overflow: TextOverflow.ellipsis,
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
