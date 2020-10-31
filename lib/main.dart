import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/controllers/App.dart';
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

  String initialRoute = "/splash";
  static const String homeRoute = "/home";
  static const String loginRoute  = "/login";
  static const String splashRoute = "/splash";

  String currentRoute;
  BuildContext _context;

  MyAppState() {
    print("rendered 1");
    print("rendered 2");
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentRoute = splashRoute;
    print("isNull");
    print(App.spotifyApi);
    _isInitialized = App.getInstance().init();

    _isInitialized.then((value) {
      homeWidgets = {"homeScreen":ChangeNotifierProvider.value(value : App.getInstance().authorization,child: HomePage(),), "loginScreen": LoginScreen()};

      print("is connected : $_isInitialized");


    });
    print(_isConnected);
  }

  Widget build(BuildContext context) {
    print("initial ? " + initialRoute);
    return MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(),
          primaryColor: Color(0xFF821E20),
          accentColor: Color(0xFF6C1719),
            backgroundColor: Color(0xFF1f2021),
          primaryColorDark: Color(0xFF6C1719)
        ),
        title: "YAY",
      home:FutureBuilder<bool>(
          future: _isInitialized,
          builder: (BuildContext context, AsyncSnapshot<bool> initialized) {
            Widget w;

            if(initialized.hasData){
              w = homeWidgets['homeScreen'];
            }else{
              w = getSplashScreen();
            }
            return w;
          },
        ),
      routes: {
          "/home": (context) => homeWidgets['homeScreen'],
          "/loginScreen": (context) => LoginScreen(),
          "/splash": (context) => getSplashScreen()
      },
      );
  }

  Widget getHome(String route){
      switch(route){
        case splashRoute:
          return getSplashScreen();
        case homeRoute:
          return ChangeNotifierProvider(create: (_) => App.getInstance().authorization,child: homeWidgets['homeScreen'],);
        case loginRoute:
          return LoginScreen();
        default:
          return getSplashScreen();
      }
  }

  Widget getSplashScreen(){
    return Container(height: double.infinity,width: double.infinity,child: Text("Initializing....."),);
  }
}
