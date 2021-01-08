import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/controllers/FeedController.dart';
import 'package:yay/controllers/LibraryController.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/controllers/RoomController.dart';
import 'package:yay/controllers/ChatController.dart';
import 'package:yay/controllers/TweetController.dart';
import 'package:yay/controllers/tweet_flow_controller.dart';
import 'package:yay/controllers/user_profile_controller.dart';

import '../ChannelConst.dart';
import 'package:http/http.dart' as http;
import 'Network.dart';

class App extends ChangeNotifier {

  static const String INIT_PREFERENCES_ATTR = "init";
  static const bool INIT_PREFERENCES_VALUE = false;

  static App spotifyApi;

  SharedPreferences appSharedPreferences;
  Socket socket;

  FirebaseApp firebaseApp;
  FirebaseDatabase firebaseDatabase;
  FirebaseAuth firebaseAuth;
  FirebaseFirestore firebaseFirestore;
  Network nt;
  Authorization authorization;
  PlayBackController playBackController;
  RoomController roomController;
  BrowserController browserController;
  FeedController feedController;
  TweetController tweetController;
  TweetFlowController tweetFlowController;
  UserProfileController userProfileController;
  App();

  static App getInstance() {
    if (spotifyApi == null) {
      spotifyApi = new App();
    }

    return spotifyApi;
  }

  Future<bool> init() async {

    firebaseApp = await Firebase.initializeApp();
    firebaseAuth = FirebaseAuth.instance;
    firebaseDatabase = FirebaseDatabase.instance;
    firebaseFirestore = FirebaseFirestore.instance;

    App.getInstance().appSharedPreferences =
        await SharedPreferences.getInstance();

    if(!App.getInstance().appSharedPreferences.containsKey(INIT_PREFERENCES_ATTR) || App.getInstance().appSharedPreferences.getBool(INIT_PREFERENCES_ATTR) == false){
      setDefaultPreference();
    }

    nt = Network();
    authorization = new Authorization(spotifyApi,firebaseAuth);
    playBackController = new PlayBackController();
    roomController = new RoomController(firebaseDatabase,firebaseAuth);
    browserController = new BrowserController(authorization);
     userProfileController = new UserProfileController(firebaseAuth);
    feedController = FeedController(firebaseFirestore,firebaseAuth);
    tweetController = TweetController();
     tweetFlowController = TweetFlowController("");
    // wait to for the app the connect to the spotify remote sdk
    await authorization.init();
  await userProfileController.init();

    await Future.delayed(new Duration(seconds: 0));
    return true;
  }

  void setDefaultPreference(){
    App.getInstance().appSharedPreferences.setBool(Authorization.LOGIN_STATUS_PREFERENCE_ATTR, false);
    App.getInstance().appSharedPreferences.setBool(INIT_PREFERENCES_ATTR, true);
  }


}
