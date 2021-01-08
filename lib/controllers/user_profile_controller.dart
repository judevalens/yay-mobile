import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:yay/controllers/Authorization.dart';

import 'App.dart';

class UserProfileController {
  static const String userProfileUrl = Authorization.ApiBaseUrl + "/auth/getUserProfile";
  Map<String, dynamic> userProfileData;

  Map<String, Map<String, dynamic>> userProfiles  = Map();
  FirebaseAuth _firebaseAuth;

  Completer<bool> isLoaded = Completer();

  UserProfileController(this._firebaseAuth) {
    loadProfile();
  }

  Future<bool> init() async {
    return await isLoaded.future;
  }

  loadProfile() {
    App.getInstance().authorization.getConnectionState().listen((isConnected) async {
      if (isConnected) {
        userProfileData = await getUserProfile(_firebaseAuth.currentUser.uid);
        print("user profile 2");
        print(userProfileData);
          isLoaded.complete(true);
      }else{
        isLoaded.complete(false);
      }
    });
  }

  addUserProfile(String userID)async {
    if (!userProfiles.containsKey(userID)){
      var profile = await getUserProfile(userID);
      userProfiles[userID]  = profile;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userID) async {

    if (userProfiles.containsKey(userID)){
      return Future.value(userProfiles[userID]);
    }
    var searchUrl = userProfileUrl + "?user_id=" + userID;

    var userProfileRes = await http.get(searchUrl);

    var userProfile = jsonDecode(userProfileRes.body);

    print("user profile");
    print(userProfile);
    return Future.value(userProfile);
  }
}