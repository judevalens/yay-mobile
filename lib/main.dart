import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/login_screen/login_screen.dart';
import 'package:yay/misc/httpsPatch.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
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
  static const String loginRoute = "/login";
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
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    currentRoute = splashRoute;
    print("isNull");
    print(App.spotifyApi);
    _isInitialized = App.getInstance().init();

    _isInitialized.then((value) {
      homeWidgets = {
        "homeScreen": ChangeNotifierProvider.value(
          value: App.getInstance().authorization,
          child: HomePage(),
        ),
        "loginScreen": LoginScreen()
      };

      print("is connected : $_isInitialized");
    });
    print(_isConnected);
  }

  Widget build(BuildContext context) {
    print("initial ? " + initialRoute);
    return MaterialApp(
      theme: ThemeData(
          textTheme: TextTheme(),
          primaryColor:Color(0xFF590004),//Color(0xFF501213),
          primaryTextTheme:TextTheme() ,
          accentColor: Colors.white,
          backgroundColor:Color(0xFF111111),
          ),
      title: "YAY",
      home: FutureBuilder<bool>(
        future: _isInitialized,
        builder: (BuildContext context, AsyncSnapshot<bool> initialized) {
          Widget w;

          if (initialized.hasData) {
            w = homeWidgets['homeScreen'];
          } else {
            w = getSplashScreen(context);
          }
          return w;
        },
      ),
      routes: {
        "/home": (context) => homeWidgets['homeScreen'],
        "/loginScreen": (context) => LoginScreen(),
        "/splash": (context) => getSplashScreen(context)
      },
    );
  }

  Widget getHome(String route, BuildContext context) {
    switch (route) {
      case splashRoute:
        return getSplashScreen(context);
      case homeRoute:
        return ChangeNotifierProvider(
          create: (_) => App.getInstance().authorization,
          child: homeWidgets['homeScreen'],
        );
      case loginRoute:
        return LoginScreen();
      default:
        return getSplashScreen(context);
    }
  }

  Widget getSplashScreen(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Container (
                decoration: BoxDecoration(border: Border.all(width: 5, color: Colors.white)),
                padding: EdgeInsets.all(15),
                child: Text("YAY",style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    decoration: TextDecoration.none
                ),),

              ) ,
            )
         ,
           Spacer(flex: 1,),
            Flexible(
              flex: 2,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.black26,
                    minHeight: 10,
                  )),
                ) ,

          ],
        ),
      ),
    );
  }
}
