import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens%20v2/profile/profile_header.dart';

class UserProfile extends StatefulWidget {
  final String userID;

  const UserProfile({Key key, this.userID}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<Map<String, dynamic>> profileData;

  String profilePictureUrl;
  String userName;
  String description;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    profileData = App.getInstance().userProfileController.getUserProfile(widget.userID);
    profileData.then((data) {
      profilePictureUrl = data["basic"]["profile_picture"];
      userName = data["basic"]["spotify_user_name"];
      description = (data["basic"]["user_desc"] as String).length > 0
          ? data["basic"]["user_desc"]
          : "No desc";
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: profileData,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          var _profileData = snapshot.data;
          return CustomScrollView(
            slivers: [
              header(),
              body(),
            ],
          );
        } else {
          return emptyProfile();
        }
      },
    );
  }

  Widget header() {
    double statusBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;

    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 300,
      flexibleSpace: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: ProfileHeader(profilePictureUrl: profilePictureUrl,userName: userName,description: description,),
      ),
    );
  }

  Widget body() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Text("body"),
      ),
    );
  }

  Widget emptyProfile() {
    return Container(
      child: CircularProgressIndicator(),
      alignment: Alignment.center,
    );
  }
}
