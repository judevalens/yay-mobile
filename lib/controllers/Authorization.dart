import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay/controllers/App.dart';
import 'package:http/http.dart' as http;

import '../ChannelConst.dart';

class Authorization extends ChangeNotifier {
  static const String ApiBaseUrl = "https://192.168.1.7:8000";

  static const String USER_EMAIL_PREFERENCE_ATTR = "userEmail";
  static const String USER_PROFILE_URL_PREFERENCE_ATTR = "userProfile";
  static const String USER_DISPLAY_NAME_PREFERENCE_ATTR = "userDisplayName";
  static const String USER_IMAGE_URL_PREFERENCE_ATTR = "userImageURL";
  static const String LOGIN_STATUS_PREFERENCE_ATTR = "isConnected";
  static const String ACCESS_TOKEN_PREFERENCE_ATTR = "accessToken";
  static const String loginUrl = ApiBaseUrl+"/auth/login";
  static const String spotifyLoginLoginUrl = ApiBaseUrl+"/auth/spotifyLogin";
  static const String freshTokenUrl = ApiBaseUrl+"/auth/spotifyGetFreshToken";
  static const String twitterRequestToken = ApiBaseUrl+"/auth/getTwitterRequestToken";
  static const String twitterAuthenticationUrl = "https://api.twitter.com/oauth/authenticate";
  static const String twitterAccessTokenUrl = ApiBaseUrl+"/auth/getTwitterAccessToken";
  static const String TwitterAuthenticationCallbackUrl = "https://127.0.0.1/twitterCallback/";


  App spotifyApi;
  String accessToken;
  int accessTokenExpireIn;
  DateTime accessTokenTimeSTamp;
  Timer tokenRefresher;
  bool isSignIn;
  bool isRemoteAppConnected;
  String userEmail;
  String userDisplayName;
  String userProfileUrl;
  String userImageUrl;
  Map<String,dynamic> userInfo;
  FirebaseAuth firebaseAuth;
  int maxTokenDuration = 3600;
  StreamController<bool> connectionState;
  MethodChannel authenticationChannel = const MethodChannel(ChannelProtocol.SPOTIFY_CHANNEL);

  Map<String,dynamic> spotifyLoginData;
  Map<String,dynamic> twitterLoginData;


  Authorization(App spotifyApi,FirebaseAuth auth) {
    this.spotifyApi = spotifyApi;
    firebaseAuth = auth;
    connectionState =  new StreamController.broadcast();


    print("remoteLoginUrl " + loginUrl);

    print("did not wait");
  }

  Future<void> init() async {
    userEmail = App.getInstance().appSharedPreferences.get(USER_EMAIL_PREFERENCE_ATTR);
    userDisplayName = App.getInstance().appSharedPreferences.get(USER_DISPLAY_NAME_PREFERENCE_ATTR);
    userProfileUrl = App.getInstance().appSharedPreferences.get(USER_PROFILE_URL_PREFERENCE_ATTR);
    userImageUrl = App.getInstance().appSharedPreferences.get(USER_IMAGE_URL_PREFERENCE_ATTR);
    await loginFlow();
    return;
  }

  Stream<bool> getConnectionState(){
    return connectionState.stream;
  }

  Future<void> loginFlow() async {
     bool isLoggedIn;
    if(firebaseAuth.currentUser != null){
    var isConnected =  await spotifySoftLogin();
      connectionState.add(true);
      setIsAuthorized(isConnected);
    }else{
      setIsAuthorized(false);
    }
  }

  Future<bool> spotifySoftLogin() async {
    isRemoteAppConnected = await connectToSpotifyRemoteApp();
    var tokenResponse = await getToken(firebaseAuth.currentUser.uid);
    accessToken = tokenResponse["access_token"];
    print(tokenResponse["expires_in"]);
    accessTokenExpireIn = tokenResponse["expires_in"];
    userInfo = tokenResponse;
    return isRemoteAppConnected;
  }

  Future<bool> spotifyHardLogin() async {
    String code = await authenticationChannel.invokeMethod("getCode");

    print("getting code");
    print("got result");
    var spotifyLoginResponse = await spotifyRemoteLogin(code);

    print("hard login answer");
    print(spotifyLoginResponse);

    print("got code " + code);

    accessToken = spotifyLoginResponse["access_token"];
    accessTokenExpireIn = spotifyLoginResponse["expires_in"];
    isRemoteAppConnected = await connectToSpotifyRemoteApp();

    // will be used in the final authentication step
    spotifyLoginData = spotifyLoginResponse;

  // if we get the spotify access token and we are connected to the remote app , we move to the next step
    return spotifyLoginResponse["status_code"] == 200 && isRemoteAppConnected;
  }

  // TODO must return a more comprehensive status
  Future<bool> hardLogin() async{
http.Request loginReq = http.Request("POST",Uri.parse(loginUrl));
loginReq.body = jsonEncode({
  "spotifyLoginData": spotifyLoginData,
  "twitterLoginData": twitterLoginData
});
loginReq.headers["Content-Type"] = "application/json";

    var loginResponse = await loginReq.send();

    var loginResponseBody = await loginResponse.stream.bytesToString();

    var loginResponseJson  = jsonDecode(loginResponseBody);

    print("res from login : " + loginResponseJson.toString());

    if (loginResponseJson["status_code"] == 200){
      userDisplayName = spotifyLoginData["display_name"];
      userImageUrl = spotifyLoginData["picture"];
      userProfileUrl = spotifyLoginData["profile"];
      App.getInstance().appSharedPreferences.setString(USER_DISPLAY_NAME_PREFERENCE_ATTR,userDisplayName);
      App.getInstance().appSharedPreferences.setString(USER_PROFILE_URL_PREFERENCE_ATTR,userProfileUrl);
      App.getInstance().appSharedPreferences.setString(USER_IMAGE_URL_PREFERENCE_ATTR,userImageUrl);
     var userCredential = await firebaseAuth.signInWithCustomToken(loginResponseJson["custom_token"]);

      // TODO must check sign in with firebaseAuth fails
      isSignIn = userCredential != null;
      connectionState.add(true);
      return isSignIn;


    }else{
      return false;
    }

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

  Future<Map<String,dynamic>> spotifyRemoteLogin(String code) async {
    print("sending req");
      var  loginResponse =  await http.post(spotifyLoginLoginUrl, headers: {
      'Content-type': 'application/json',
    }, body: jsonEncode({
      "access_code" : code,
    }));
    return  jsonDecode(loginResponse.body);

  }
  Future<Map<String,dynamic>> getToken(String userUUID) async {
    print("sending req");

    var getFreshTokenUrl = Uri.parse(freshTokenUrl);
    var finalGetFreshTokenUrl  =  Uri.https(getFreshTokenUrl.authority, getFreshTokenUrl.path,{
      "user_uuid": userUUID
    });
    var getFreshTokeResponse =  await http.get(finalGetFreshTokenUrl);

    return  jsonDecode(getFreshTokeResponse.body);
  }

  String getSpotifyToken(){
    return "Bearer "+accessToken;
  }

  Future<Map<String,dynamic>> twitterGetRequestToken() async{
    Map<String,dynamic> res;
    var response = await http.get(twitterRequestToken);
    print('RES FROM TWITTER REQUEST ' + response.body);
    var responseJson = jsonDecode(response.body);
    print(responseJson);
    responseJson["action"] = "sendToTwitter";
    responseJson["url"] = twitterAuthenticationUrl + "?oauth_token="+responseJson["oauth_token"];
    return responseJson;
  }
  Future<bool> twitterAccessToken(String url) async{
    Uri uri = Uri.parse(url);
    var oauthToken = uri.queryParameters["oauth_token"];
    var oauthVerifier = uri.queryParameters["oauth_verifier"];
    var accessTokenUrl = twitterAccessTokenUrl+"?oauth_token="+oauthToken+"&oauth_verifier="+oauthVerifier;
    print("OAUTH TOKEN : " + oauthToken + ", oauthVerifier : " +oauthVerifier);
   Map<String,dynamic> res;
    var response = await http.get(accessTokenUrl);
    print('RES FROM TWITTER REQUEST ' + response.body);
    var loginResponse = jsonDecode(response.body);
    print(loginResponse);
    twitterLoginData = loginResponse;
    print("twitter status code " + (loginResponse["status_code"] == 200).toString());
    return loginResponse["status_code"] == 200;
  }
}
