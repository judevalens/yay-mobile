 import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
 import 'package:http/http.dart' as http;

class Authorization extends ChangeNotifier{
  static const String USER_EMAIL_PREFERENCE_ATTR = "userEmail";
  static const String LOGIN_STATUS_PREFERENCE_ATTR = "isConnected";
  static const String ACCESS_TOKEN_PREFERENCE_ATTR = "accessToken";
  App spotifyApi;
  bool isSignIn;
  bool isRemoteAppConnected;
  bool isAuthorized = false;
  String userEmail;

  Authorization(App spotifyApi){
    this.spotifyApi = spotifyApi;
     print("did not wait");
  }

  Future<void> init() async{
    userEmail = App.getInstance().appSharedPreferences.get(USER_EMAIL_PREFERENCE_ATTR);
    isSignIn =  App.getInstance().appSharedPreferences.get(LOGIN_STATUS_PREFERENCE_ATTR);
    print("isSign :" + isSignIn.toString());
    if(isSignIn){
      print("isSign2 :" + isSignIn.toString());
      isRemoteAppConnected = await connectToSpotifyRemoteApp();
      print("isRemoteAppConnected :" + isRemoteAppConnected.toString());
    }

    return;
  }

  void login() {
    Future<String> loginResult = App.spotifyApi.platform.invokeMethod("login");
    loginResult.then((value) async {

      Map<String, dynamic> loginResultJson = jsonDecode(value);
      var userProfile = await http.get("https://api.spotify.com/v1/me",
          headers: {
            "Authorization": "Bearer " + loginResultJson["access_token"]
          });

      var userProfileJson = json.decode(userProfile.body);
      App.spotifyApi.appSharedPreferences
          .setString(USER_EMAIL_PREFERENCE_ATTR, userProfileJson["email"]);
      //TODO remove this later
      print("http response");
      print(userProfileJson);
      App.spotifyApi.appSharedPreferences
          .setString(ACCESS_TOKEN_PREFERENCE_ATTR, loginResultJson["access_token"]);

      isRemoteAppConnected = await connectToSpotifyRemoteApp();
      App.spotifyApi.appSharedPreferences
          .setBool(LOGIN_STATUS_PREFERENCE_ATTR,true);
      setIsAuthorized(true);
      isSignIn = true;
      isRemoteAppConnected = true;
      print("loginResultJson");
      print(loginResultJson);
    }).catchError((err) {});
  }

  Future<bool> connectToSpotifyRemoteApp()  async {
    Future<bool> spotifyAppRemoteConnectionResult =
    App.spotifyApi.platform.invokeMethod("connectToSpotifyApp");
    return spotifyAppRemoteConnectionResult;
  }

  void setIsAuthorized(bool b){
    isAuthorized = true;
    notifyListeners();
  }

  bool getAuthorization(){
    isAuthorized = isSignIn == true && isRemoteAppConnected == true;

    return isAuthorized;
  }

  void logOut(){
    isSignIn = false;
    isAuthorized = false;
    isRemoteAppConnected = false;
    print("logged out");
    notifyListeners();
  }

}