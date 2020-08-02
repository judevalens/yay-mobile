import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpotifyApi extends ChangeNotifier{
 static SpotifyApi instanceOfSpotifyApi;
 bool isConnected  = false;
 bool isPaused = false;
 int currentTrackDuration = 0;
 int currentTrackPosition = 0;
 String currentTrackTitle ;
 static const platform = const MethodChannel('yay.homepage/initSpotify');

  SpotifyApi();


  static SpotifyApi getSpotifyAPI(){
    if (instanceOfSpotifyApi == null){
      instanceOfSpotifyApi = SpotifyApi();
      return instanceOfSpotifyApi;
    }
    return instanceOfSpotifyApi;
  }

  void connect (){
    Future<String> result = platform.invokeMethod('connect');

    result.then((value) {
      print("result from Spotify : $value\n");
    });
  }
  
  void playMusic (){
    platform.invokeMethod("play");
  }

  void pauseMusic(){
    platform.invokeMethod("pause");
  }

  void seek(double position){
    platform.invokeMethod("seek",[position]);
  }



}