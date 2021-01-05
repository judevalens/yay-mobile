import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:http/http.dart' as http;
class UserProfileController {
  static const String userProfileUrl = Authorization.ApiBaseUrl+"/auth/getUserProfile";
  FirebaseAuth _firebaseAuth;
  UserProfileController(this._firebaseAuth);

  Future<Map<String, dynamic>> getUserProfile(String userID) async {
    var searchUrl =userProfileUrl+"?user_id="+userID;

    var userProfileRes = await http.get(searchUrl);

    var userProfile = jsonDecode(userProfileRes.body);

    print("user profile");
    print(userProfile);
    return Future.value(userProfile);
  }
}