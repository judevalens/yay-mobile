import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/login_screen/login_screen.dart';
import 'package:yay/screens/home_screen//room_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SpotifyApi.getSpotifyAPI(),
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
  Map<String, Widget> homeWidgets;

  MyAppState() {
    print("rendered 1");
    print("rendered 2");
    WidgetsFlutterBinding.ensureInitialized();
    Socket socket = io("http://192.168.1.3:5000");
    homeWidgets = {
      "homeScreen": HomePage(socket),
      "loginScreen": LoginScreen()
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }



  Widget build(BuildContext context) {
    return Selector<SpotifyApi, bool>(selector: (buildContext, spotifyApi) {
      return spotifyApi.isConnected;
    }, builder: (ctx, data, child) {
      return MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(),
        ),
        title: "YAY",
        home: FutureBuilder(
          future: SpotifyApi.getSpotifyAPI().getConnectionState(),
          builder: (BuildContext context, AsyncSnapshot<bool> isConnected) {
            return isConnected.data
                ? homeWidgets["homeScreen"]
                : homeWidgets["loginScreen"];
          },
        ),
      );
    });
  }
}
