import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/user_model.dart';

import 'App.dart';

class UserController {
  static const String userProfileUrl = Authorization.ApiBaseUrl + "/auth/getUserProfile";
  static const String isFollowingUrl = Authorization.ApiBaseUrl + "";
  Future<UserModel> userProfileData;

  Map<String, UserModel> userProfiles = Map();
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  Completer<bool> isLoaded = Completer();

  SingleSCMultipleSubscriptions<Map<String, UserModel>> friendsStream =
      SingleSCMultipleSubscriptions();
  Map<String, UserModel> friends;

  UserController(this._firebaseAuth, this._firestore) {
    loadProfile();
  }

  Future<bool> init() async {
    return await isLoaded.future;
  }

  loadProfile() {
    App.getInstance().authorization.getConnectionState().listen((isConnected) async {
      if (isLoaded.isCompleted) {
        isLoaded = Completer();
      }
      if (isConnected) {
        userProfileData = getUser(_firebaseAuth.currentUser.uid);
        print("user profile 2");
        print(userProfileData);

        isLoaded.complete(true);
      } else {
        isLoaded.complete(false);
      }
    });
  }

  loadFriends(String currentUserID) {
    _firestore
        .collection("users")
        .doc(currentUserID)
        .collection("followed_users")
        .snapshots()
        .listen((friendsSnapShot) {
      friendsSnapShot.docChanges.forEach((friendID) async {
        friends[friendID.doc.id] = await getUser(friendID.doc.id);
        friendsStream.controller.add(friends);
      });
    });
  }

  addUserProfile(String userID) async {
    if (!userProfiles.containsKey(userID)) {
      var user = await getUser(userID);
      userProfiles[userID] = user;
    }
  }

  Future<UserModel> getUser(String userID) async {
    if (userProfiles.containsKey(userID)) {
      return Future.value(userProfiles[userID]);
    }
    var searchUrl = userProfileUrl + "?user_id=" + userID;

    var userProfileRes = await http.get(searchUrl);

    var userProfile = jsonDecode(userProfileRes.body);

    var user = UserModel(userProfile, this, userID, _firebaseAuth.currentUser.uid);

    print("user profile");
    print(userProfile);
    return Future.value(user);
  }

  Future<bool> isFollowing(String userIdA, String userIdB) async {
    var isFollowingUri = Uri.http(Authorization.ApiAuthority, "relation/isFollowingUser", {
      "user_a_id": userIdA,
      "user_b_id": userIdB,
    });

    var isFollowingRes = await http.get(isFollowingUri);

    var isFollowingResJson = jsonDecode(isFollowingRes.body);

    if (isFollowingResJson["status"] == 200) {
      return isFollowingResJson["isFollowing"];
    } else {
      return false;
    }
  }

  Stream<DocumentSnapshot> getFollowingStatus(String userIdA, userIdB) {
    return _firestore
        .collection("users")
        .doc(userIdA)
        .collection("followed_users")
        .doc(userIdB)
        .snapshots();
  }

  followUser(String currentUserID, String userToFollowID) async {
    var followUrl = Uri.https(Authorization.ApiAuthority, "relation/friendUsers",
        {"user_a_id": currentUserID, "user_b_id": userToFollowID});

    var followUrlRes = await http.get(followUrl);
    var followUrlResJson = jsonDecode(followUrlRes.body);

    return followUrlResJson["status"] == 200;
  }
}
