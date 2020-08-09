import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyApi extends ChangeNotifier {
  static SpotifyApi _instanceOfSpotifyApi;
  bool isConnected = false;
  bool isPaused = false;
  int currentTrackDuration = 0;
  int currentTrackPosition = 0;
  double trackPositionTimeStamp = 0;
  String currentTrackTitle;
  static const platform = const MethodChannel('yay.homepage/initSpotify');
  Future<bool> connectionState;

  SpotifyApi();

  static SpotifyApi getSpotifyAPI() {
    if (_instanceOfSpotifyApi == null) {
      _instanceOfSpotifyApi = SpotifyApi();
      platform.setMethodCallHandler((call) {

      });

      return _instanceOfSpotifyApi;
    }
    return _instanceOfSpotifyApi;
  }

  void connect() {
    Future<String> result = platform.invokeMethod('connect');

    result.then((value) {
      print("result from Spotify : $value\n");
    });
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

  void updateConnectionStatus(bool val){
    isConnected = val;
    notifyListeners();
  }

  Future<bool> getConnectionState () async{
    return isConnected;
  }


  void songProgress(){
    Timer.periodic(Duration(milliseconds: 10), (timer) {

    });
  }
}
