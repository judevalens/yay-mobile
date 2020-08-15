import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/login_screen/login_screen.dart';
import 'package:yay/screens/home_screen//room_page.dart';

void main() {
  var sa = SpotifyApi.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => sa,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  Widget widgetToRender = Text("waiting");
  Future<bool> _isConnected;
  Map<String, Widget> homeWidgets;

  MyAppState() {
    print("rendered 1");
    print("rendered 2");
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("isNull");
    print(SpotifyApi.spotifyApi);

    homeWidgets = {
      "homeScreen": HomePage(),
      "loginScreen": LoginScreen()
    };
    SpotifyApi.init();
    _isConnected = SpotifyApi.spotifyApi.connect();
  }

  Widget build(BuildContext context) {
    return Selector<SpotifyApi, bool>(selector: (buildContext, spotifyApi) {
      //_isConnected = SpotifyApi.spotifyApi.connect();

      return spotifyApi.isConnected;
    }, builder: (ctx, data, child) {
      return MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(),
        ),
        title: "YAY",
        home: FutureBuilder(
          future: _isConnected,
          builder: (BuildContext context, AsyncSnapshot<bool> isConnected) {
            Widget w = Text("waiting......");
            if (isConnected.hasData) {
              w = isConnected.data
                  ? homeWidgets["homeScreen"]
                  : homeWidgets["loginScreen"];
            }
            return w;
          },
        ),
      );
    });
  }
}
