import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/login_screen/login_screen.dart';
import 'package:yay/screens/rooms_screen/room_page.dart';

void main() {
  runApp(
     MyApp(),
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
  Future<bool> _isInitialized;
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

    homeWidgets = {"homeScreen": HomePage(), "loginScreen": LoginScreen()};
    _isInitialized = SpotifyApi.getInstance().init();

    _isInitialized.then((value) {
      print("is connected : $_isInitialized");

    });
    print(_isConnected);
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(),
        ),
        title: "YAY",
        home: FutureBuilder<bool>(
          future: _isInitialized,
          builder: (BuildContext context, AsyncSnapshot<bool> initialized) {
            Widget w;

            if(initialized.hasData){
              w = ChangeNotifierProvider(create: (_) => SpotifyApi.getInstance().authorization,child: homeWidgets['homeScreen'],);
            }else{
              w = Text("waiting......");
            }
            return w;
          },
        ),
      );

  }
}
