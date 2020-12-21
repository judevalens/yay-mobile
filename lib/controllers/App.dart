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
    feedController = FeedController(firebaseFirestore);
    // wait to for the app the connect to the spotify remote sdk
    await authorization.init();
    var s = await feedController.fetch(0);
    print("snap shot res : " + s.toString() + " start index " + feedController.startIndex.toString() + " end index "+feedController.endIndex.toString());

    await Future.delayed(new Duration(seconds: 2));
    return true;
  }

  void setDefaultPreference(){
    App.getInstance().appSharedPreferences.setBool(Authorization.LOGIN_STATUS_PREFERENCE_ATTR, false);
    App.getInstance().appSharedPreferences.setBool(INIT_PREFERENCES_ATTR, true);
  }

  /*
  void login() {
    Future<String> loginResult =
        App.spotifyApi.platform.invokeMethod("login");
    loginResult.then((value) async {
      Map<String, dynamic> loginResultJson = jsonDecode(value);

      var userProfile = await http.get("https://api.spotify.com/v1/me",
          headers: {
            "Authorization": "Bearer " + loginResultJson["access_token"]
          });

      var userProfileJson = json.decode(userProfile.body);
      App.spotifyApi.appSharedPreferences
          .setString("userEmail", userProfileJson["email"]);
      //TODO remove this later
      print("http response");
      print(userProfileJson);

      Future<bool> spotifyAppRemoteConnectionResult =
          App.spotifyApi.platform.invokeMethod("connectToSpotifyApp");
      spotifyAppRemoteConnectionResult.then((value) {
        App.spotifyApi.appSharedPreferences.setBool("isConnected", true);
        App.spotifyApi.spotifyApiCredentials = loginResultJson;
        App.spotifyApi.appSharedPreferences
            .setString("accessToken", loginResultJson["access_token"]);

        nt.socket.connect();
        App.spotifyApi.updateConnectionStatus(true);
      });
      print("loginResultJson");
      print(loginResultJson);
    }).catchError((err) {});
  }

  Future<bool> connect() async {
    Future<bool> connectionResult;
    if (isConnected && isAuthenticated) {
      return true;
    } else if (!(appSharedPreferences.containsKey("isConnected")
        ? appSharedPreferences.getBool("isConnected")
        : false)) {
      return false;
    } else {
      print("connecting to remote");
      connectionResult = platform.invokeMethod("connectToSpotifyApp");
      connectionResult.then((value) {
        updateConnectionStatus(true);
        isAuthenticated = true;
        print("connectedToRemote");
        nt.socket.connect();
        return true;
      });
      return connectionResult;
    }
  }

  void disconnect() {
    spotifyApi.appSharedPreferences.remove("isConnected");
    spotifyApi.appSharedPreferences.remove("accessToken");
    spotifyApi.appSharedPreferences.remove("userEmail");
    App.getInstance().updateConnectionStatus(false);
  }

  void playMusic() {
    platform.invokeMethod("play");
  }

  void pauseMusic() {
    platform.invokeMethod("pause");
  }

  void seek(double position) {
    platform.invokeMethod("seek", [position]);
  }

  void updateConnectionStatus(bool val) {
    isConnected = val;
    notifyListeners();
  }

  void updatePlayerState(Map<String, dynamic> _playerState) {
    playerState = _playerState;
    if (songPositionUpdaterSp != null) {
      songPositionUpdaterSp.send(playerState);
    }
  }

  Future<bool> getConnectionState() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    isConnected = sp.getBool("isConnected");
    return isConnected;
  }

  Future<void> connectToRemote() async {
    bool connectionResult = await platform.invokeMethod("connectToSpotifyApp");
  }
*/
  static void songProgress(SendPort sp) {
    print("new state!!!!!");

    int currentTrackPosition = 0;
    ReceivePort songPositionUpdaterRp = ReceivePort();
    sp.send(songPositionUpdaterRp.sendPort);
    Timer timer;
    songPositionUpdaterRp.listen((playerState) {
      currentTrackPosition = playerState["playback_position"];
      if (playerState is Map<String, dynamic>) {
        print("new state!!!!! 1");
        if (playerState["is_paused"]) {
          if (timer != null) {
            timer.cancel();
            timer = null;
          }
        } else {
          if (timer == null) {
            timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
              currentTrackPosition += 1;
              sp.send(currentTrackPosition);
            });
          }
        }
      }
    });
  }
}
