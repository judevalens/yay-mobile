 import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yay/controllers/SpotifyApi.dart';
 import 'package:http/http.dart' as http;

class Authorization extends ChangeNotifier{
  static const String USER_EMAIL_PREFERENCE_ATTR = "userEmail";
  static const String LOGIN_STATUS_PREFERENCE_ATTR = "isConnected";
  static const String ACCESS_TOKEN_PREFERENCE_ATTR = "accessToken";
  SpotifyApi spotifyApi;
  bool isSignIn;
  bool isRemoteAppConnected;
  bool isAuthorized = false;
  String userEmail;

  Authorization(SpotifyApi spotifyApi){
    this.spotifyApi = spotifyApi;

    init();
  }

  void init() async{
    userEmail = SpotifyApi.getInstance().appSharedPreferences.get(USER_EMAIL_PREFERENCE_ATTR);
    isSignIn =  SpotifyApi.getInstance().appSharedPreferences.get(LOGIN_STATUS_PREFERENCE_ATTR);
    print("isSign :" + isSignIn.toString());
    if(isSignIn){
      print("isSign2 :" + isSignIn.toString());

      isRemoteAppConnected = await connectToSpotifyRemoteApp();
    }
  }

  void login() {
    Future<String> loginResult = SpotifyApi.spotifyApi.platform.invokeMethod("login");
    loginResult.then((value) async {

      Map<String, dynamic> loginResultJson = jsonDecode(value);
      var userProfile = await http.get("https://api.spotify.com/v1/me",
          headers: {
            "Authorization": "Bearer " + loginResultJson["access_token"]
          });

      var userProfileJson = json.decode(userProfile.body);
      SpotifyApi.spotifyApi.appSharedPreferences
          .setString(USER_EMAIL_PREFERENCE_ATTR, userProfileJson["email"]);
      //TODO remove this later
      print("http response");
      print(userProfileJson);
      SpotifyApi.spotifyApi.appSharedPreferences
          .setString(ACCESS_TOKEN_PREFERENCE_ATTR, loginResultJson["access_token"]);

      isRemoteAppConnected = await connectToSpotifyRemoteApp();

      setIsAuthorized(true);

      print("loginResultJson");
      print(loginResultJson);
    }).catchError((err) {});
  }

  Future<bool> connectToSpotifyRemoteApp()  async {
    Future<bool> spotifyAppRemoteConnectionResult =
    SpotifyApi.spotifyApi.platform.invokeMethod("connectToSpotifyApp");
    return spotifyAppRemoteConnectionResult;
  }

  void setIsAuthorized(bool b){
    isSignIn = true;
    isRemoteAppConnected = true;
    notifyListeners();
  }

  bool getAuthorization(){
    isAuthorized = isSignIn == true && isRemoteAppConnected == true;

    return isAuthorized;
  }


}