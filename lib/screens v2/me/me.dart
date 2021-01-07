import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/ChatController.dart';
import 'package:yay/screens%20v2/me/chats.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';
import 'package:yay/screens/setting_screen/setting_screen.dart';

class Me extends StatefulWidget {
  @override
  _MeState createState() => _MeState();
}

class _MeState extends State<Me> with TickerProviderStateMixin {
  TabController _controller;
  PageController _pageController;
  Map<String, dynamic> userProfileData;
  String userProfile;
  String userName;
  String userId;

  ChatController _chatController = App.getInstance().roomController.chatController;

  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(vsync: this, length: 2);
    _pageController = PageController();
    userProfileData = App.getInstance().userProfileController.userProfileData;
    userProfile = userProfileData["basic"]["profile_picture"];
    userName = userProfileData["basic"]["spotify_user_name"];
    userId = App.getInstance().authorization.firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [header(), body()],
      ),
    );
  }

  Widget header() {
    return SliverAppBar(
      title: myProfile(userProfile, userName, userId),
      floating: true,
      pinned: true,
      bottom: TabBar(
        controller: _controller,
        tabs: [
          Tab(
            text: "Listening sessions",
          ),
          Tab(
            text: "Friends",
          )
        ],
      ),
    );
  }

  Widget body() {
    return SliverFillRemaining(
      hasScrollBody: true,
      fillOverscroll: true,
      child: Container(
        child: PageView(
          children: [ChatList(chatController: _chatController,)],
        ),
      ),
    );
  }

  Widget body2() {
    return SliverList(
      delegate: SliverChildListDelegate([]),
    );
  }

  Widget myProfile(String profileUrl, String name, String userID) {
    return GestureDetector(
      onTap: () {
        print("tapped artist");
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return UserProfile(
            userID: userID,
          );
        }));
      },
      child: Container(
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 5),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary)),
              child: ClipOval(
                child: profileUrl != null
                    ? Image.network(
                        profileUrl,
                        fit: BoxFit.fill,
                      )
                    : Placeholder(),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    name,
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

  Widget signOut() {
    return Container(
      alignment: Alignment.center,
      child: MaterialButton(
        child: Icon(Icons.logout),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Setting();
              },
            ),
          );
        },
      ),
    );
  }
}
