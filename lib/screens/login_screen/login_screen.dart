import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yay/ChannelConst.dart';
import 'package:http/http.dart' as http;
import 'package:yay/controllers/App.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: FractionallySizedBox(
          heightFactor: 0.1,
          widthFactor: 0.8,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xff1DB954),
              borderRadius: BorderRadius.circular(90),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: RaisedButton(
                color: Color(0xff1DB954),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(90),
                ),
                onPressed: () {
                  App.getInstance().authorization.hardLogin().then((value) => (
                      Navigator.pushNamedAndRemoveUntil(context, "/home",(route) => false)
                  ));
                  //Navigator.popAndPushNamed(context, "/home",);
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/Spotify_Icon_RGB_White.png",
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Login with Spotify",
                        style: TextStyle(color: Colors.white),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
