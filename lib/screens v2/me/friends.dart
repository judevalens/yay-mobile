import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/user_model.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: App.getInstance().userProfileController.friendsStream.getStream(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, UserModel>> snapshot) {
          if (snapshot.hasData) {
            var friendIDs = snapshot.data.keys.toList();
            return ListView.builder(
                itemCount: friendIDs.length,
                itemBuilder: (context, index) {
                  return friendItem(snapshot.data[friendIDs[index]]);
                });
          } else {
            return emptyList();
          }

          return null;
        },
      ),
    );
  }

  Widget friendItem(UserModel user) {
    var profilePictureUrl = user.userProfile["basic"]["profile_picture"];
    profilePictureUrl = profilePictureUrl.length == 0 ? null : profilePictureUrl;
    return GestureDetector(
      onTap: () {
        print("tapped artist");
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return UserProfile(userID: user.userID,);
        }));
      },
      child: Container(
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: ClipOval(
                child: profilePictureUrl != null
                    ? Image.network(
                  profilePictureUrl,
                  fit: BoxFit.fill,
                )
                    : Container(
                  child: Icon(Icons.account_circle,size: 60,),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    //TODO clean this up. this work should be done in the userModel!!!!
                    user.userProfile["basic"]["spotify_user_name"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyList() {
    return Container(
      child: Text("No Friends, Search for new ones!!!"),
    );
  }
}
