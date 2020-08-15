import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../ChannelConst.dart';

class SpotifyApi extends ChangeNotifier {
  static SpotifyApi spotifyApi;
  bool isConnected = false;
  bool isPaused = false;
  int currentTrackDuration = 0;
  int currentTrackPosition = 0;

  Map<String, dynamic> spotifyApiCredentials;
  Map<String, dynamic> playerState;
  DateTime lastUpdatedPositionTimeStamp;

  String currentTrackTitle;
  MethodChannel platform = const MethodChannel(ChannelProtocol.SPOTIFY_CHANNEL);
  Future<bool> connectionState;
  ReceivePort songPositionUpdaterRp;
  SendPort songPositionUpdaterSp;
  static bool isInitialized;

  SharedPreferences appSharedPreferences;
  Socket socket;
  SpotifyApi();

  static SpotifyApi getInstance() {

    if (spotifyApi == null){
      spotifyApi = new SpotifyApi();
    }

    return spotifyApi;
  }

  static Future<void> init() async {
    SpotifyApi.getInstance().appSharedPreferences = await SharedPreferences.getInstance();
    SpotifyApi.getInstance().socket = io("http://192.168.1.3:5000");

    spotifyApi.platform.setMethodCallHandler((call) {
      print("player state changed !! Flutter");

      switch (call.method) {
        case "updatePlayerState":
          var playerState = jsonDecode(call.arguments);
          spotifyApi.updatePlayerState(playerState);
      }

      return null;
    });
    print("set call back");

    spotifyApi.songPositionUpdaterRp = ReceivePort();
    Future<Isolate> songUpdaterIsolate = Isolate.spawn(
        SpotifyApi.songProgress, spotifyApi.songPositionUpdaterRp.sendPort);

    spotifyApi.songPositionUpdaterRp.listen((msg) {
      if (msg is SendPort) {
        spotifyApi.songPositionUpdaterSp = msg;
      } else if (msg is int) {
        print("new pos  $msg\n");
        spotifyApi.playerState["playback_position"] = msg;
        spotifyApi.notifyListeners();
      }
    });
  }

  Future<bool> connect() async {
    SharedPreferences sp  = await SharedPreferences.getInstance();
    isConnected = sp.getBool("isConnected");
    print("isConnected $isConnected");
    if (!isConnected){
      return false;
    }
    Future<bool> connectionResult = platform.invokeMethod("connectToSpotifyApp");
    connectionResult.then((value) {
      //updateConnectionStatus(true);
      print("connectedToRemote");
      return true;
    });
    return connectionResult;
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
    SharedPreferences sp  = await SharedPreferences.getInstance();
    isConnected = sp.getBool("isConnected");


    return isConnected;
  }

  Future<void> connectToRemote() async{
    Future<String> connectionResult = await platform.invokeMethod("connectToSpotifyApp");
    connectionResult.then((value) {

    });

  }

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
