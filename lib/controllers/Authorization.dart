import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay/controllers/App.dart';
import 'package:http/http.dart' as http;

import '../ChannelConst.dart';

class Authorization extends ChangeNotifier {
  static const String USER_EMAIL_PREFERENCE_ATTR = "userEmail";
  static const String LOGIN_STATUS_PREFERENCE_ATTR = "isConnected";
  static const String ACCESS_TOKEN_PREFERENCE_ATTR = "accessToken";
  App spotifyApi;
  String accessToken;
  int accessTokenExpireIn;
  DateTime accessTokenTimeSTamp;
  Timer tokenRefresher;
  bool isSignIn;
  bool isRemoteAppConnected;
  String userEmail;


  FirebaseAuth firebaseAuth;

  int maxTokenDuration = 3600;
  StreamController<bool> connectionState;

  MethodChannel authenticationChannel = const MethodChannel(ChannelProtocol.SPOTIFY_CHANNEL);

  static const String remoteLoginUrl = "http://129.21.70.250:8000/login";
  static const String freshTokenUrl = "http://129.21.70.250:8000/getFreshToken";

  Authorization(App spotifyApi,FirebaseAuth auth) {
    this.spotifyApi = spotifyApi;
    firebaseAuth = auth;
    connectionState =  new StreamController();

    print("did not wait");
  }

  Future<void> init() async {
    userEmail = App.getInstance().appSharedPreferences.get(USER_EMAIL_PREFERENCE_ATTR);
    isSignIn = App.getInstance().appSharedPreferences.get(LOGIN_STATUS_PREFERENCE_ATTR);
    await loginFlow();

    return;
  }


  Stream<bool> getConnectionState(){
    return connectionState.stream;
  }

  Future<void> loginFlow() async {
     bool isLoggedIn;
    if(firebaseAuth.currentUser != null){
    var isConnected =  await softLogin();
      connectionState.add(true);
      setIsAuthorized(isConnected);
    }else{
      setIsAuthorized(false);
    }
  }

  Future<bool> softLogin() async {
    isRemoteAppConnected = await connectToSpotifyRemoteApp();
    var tokenResponse = await getToken(firebaseAuth.currentUser.uid);
    accessToken = tokenResponse["access_token"];
    accessTokenExpireIn = tokenResponse["expires_in"];
    return isRemoteAppConnected;
  }

  Future<bool> hardLogin() async {
    String code = await authenticationChannel.invokeMethod("getCode");

    print("getting code");
    print("got result");
    var loginResponse = await remoteLogin(code);

    print("hard login answer");
    print(loginResponse);

    var userCredential = await firebaseAuth.signInWithCustomToken(loginResponse["custom_token"]);

    var firebaseAuthSuccessful = userCredential != null;

    print("got code " + code);

    // accessToken = accessTokenResult["access_token"];
    isRemoteAppConnected = await connectToSpotifyRemoteApp();

    connectionState.add(true);

    return Future<bool>.value(isRemoteAppConnected && firebaseAuthSuccessful);
  }

  void connectionStateListener(){
    firebaseAuth.authStateChanges().listen((User user) {
      if (user != null){
        //log out
      }else{
        // log out
      }
    });
  }

  Future<bool> connectToSpotifyRemoteApp() async {
    Future<bool> spotifyAppRemoteConnectionResult =
        authenticationChannel.invokeMethod("connectToSpotifyApp");
    return spotifyAppRemoteConnectionResult;
  }

  void setIsAuthorized(bool b) {
    notifyListeners();
  }

  bool isAuthorized() {
    return (firebaseAuth.currentUser != null) && isRemoteAppConnected == true;
  }

  void logOut() {
    isSignIn = false;
    isRemoteAppConnected = false;
    firebaseAuth.signOut();
    print("logged out");
    notifyListeners();
  }

  void saveAccessToken(Map<String, dynamic> accessResponse) {
    accessTokenTimeSTamp = new DateTime.now();
   // accessToken["lastTimeStamp"] = new DateTime.now().millisecondsSinceEpoch;
    App.spotifyApi.appSharedPreferences
        .setString(ACCESS_TOKEN_PREFERENCE_ATTR, jsonEncode(accessResponse));
  }

  Future<Map<String,dynamic>> remoteLogin(String code) async {
    print("sending req");
      var  loginResponse =  await http.post(remoteLoginUrl, headers: {
      'Content-type': 'application/json',
    }, body: jsonEncode({
      "Code" : code,
    }));
    return  jsonDecode(loginResponse.body);

  }
  Future<Map<String,dynamic>> getToken(String userUUID) async {
    print("sending req");

    var getFreshTokenUrl = Uri.parse(freshTokenUrl);
    var finalGetFreshTokenUrl  =  Uri.http(getFreshTokenUrl.authority, getFreshTokenUrl.path,{
      "userUUID": userUUID
    });
    var getFreshTokeResponse =  await http.get(finalGetFreshTokenUrl);

    return  jsonDecode(getFreshTokeResponse.body);
  }

/*
  void updatedToken(String accessToken){
    tokenRefresher =    Timer.periodic(new Duration(hours: 58), (timer) {
          authenticationChannel.invokeMethod("getToken");
          String authorizationHeader = CLIENT_ID + ":" + CLIENT_SECRET;
          Base64Encoder base64encoder  = new Base64Encoder();
          String AuthorizationHeader64 =  " Basic " + base64encoder.convert(authorizationHeader.runes.toList());


          Uri url = Uri.parse("https://accounts.spotify.com/api/token");
          http.Request  req = new http.Request("POST", url);

          req.
          
      });
  }
  */

}
