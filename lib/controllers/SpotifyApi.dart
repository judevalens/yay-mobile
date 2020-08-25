import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../ChannelConst.dart';
import 'package:http/http.dart' as http;
import 'Network.dart';

class SpotifyApi extends ChangeNotifier {
  static SpotifyApi spotifyApi;
  bool isInitialized;
  bool isConnected = false;
  bool isAuthenticated = false;
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

  SharedPreferences appSharedPreferences;
  Socket socket;

  SpotifyApi();

  Network nt;

  static SpotifyApi getInstance() {
    if (spotifyApi == null) {
      spotifyApi = new SpotifyApi();
      spotifyApi.nt = Network();
    }

    return spotifyApi;
  }

  static Future<bool> init() async {
    SpotifyApi.getInstance().appSharedPreferences =
        await SharedPreferences.getInstance();

    var userEmail =
        SpotifyApi.getInstance().appSharedPreferences.get("userEmail");

    print("user email \n " + "$userEmail");

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

    var isConnected = await SpotifyApi.getInstance().connect();
    return isConnected;
  }

  void login() {
    Future<String> loginResult =
        SpotifyApi.spotifyApi.platform.invokeMethod("login");
    loginResult.then((value) async {
      Map<String, dynamic> loginResultJson = jsonDecode(value);
      var userProfile = await http.get("https://api.spotify.com/v1/me",
          headers: {
            "Authorization": "Bearer " + loginResultJson["access_token"]
          });
      var userProfileJson = json.decode(userProfile.body);
      SpotifyApi.spotifyApi.appSharedPreferences
          .setString("userEmail", userProfileJson["email"]);
      //TODO remove this later
      print("http response");
      print(userProfileJson);

      Future<bool> spotifyAppRemoteConnectionResult =
          SpotifyApi.spotifyApi.platform.invokeMethod("connectToSpotifyApp");
      spotifyAppRemoteConnectionResult.then((value) {
        SpotifyApi.spotifyApi.appSharedPreferences.setBool("isConnected", true);
        SpotifyApi.spotifyApi.spotifyApiCredentials = loginResultJson;
        SpotifyApi.spotifyApi.appSharedPreferences
            .setString("accessToken", loginResultJson["access_token"]);

        nt.socket.connect();
        SpotifyApi.spotifyApi.updateConnectionStatus(true);
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
      connectionResult = platform.invokeMethod("connectToSpotifyApp");
      connectionResult.then((value) {
        //updateConnectionStatus(true);
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
    SpotifyApi.getInstance().updateConnectionStatus(false);
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
