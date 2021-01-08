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
  List<Map<String, dynamic>> topTracks;
  List<Map<String, dynamic>> topArtists;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    profileData = App.getInstance().userProfileController.getUserProfile(widget.userID);
    profileData.then((data) {
      profilePictureUrl = data["basic"]["profile_picture"];
      profilePictureUrl = profilePictureUrl.length == 0 ? null : profilePictureUrl;

      userName = data["basic"]["spotify_user_name"];
      description = (data["basic"]["user_desc"] as String).length > 0
          ? data["basic"]["user_desc"]
          : "No desc";
      topTracks = ((data["topTracks"] as Map<String, dynamic>)["items"] as List)
          .cast<Map<String, dynamic>>();
      topArtists = ((data["topArtists"] as Map<String, dynamic>)["items"] as List)
          .cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: profileData,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            var _profileData = snapshot.data;
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      padding: EdgeInsets.only(top: 10),
                      child: ProfileHeader(
                        profilePictureUrl: profilePictureUrl,
                        userName: userName,
                        description: description,
                      ),
                    ),
                    topTrack(),
                    topArtist(),
                  ],
                ),
              ),
            );

          } else {
            return emptyProfile();
          }
        },
      ),
    );
  }

  Widget header() {
    double statusBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;

    return SliverAppBar(
      floating: true,
      expandedHeight: 300,
      flexibleSpace: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: ProfileHeader(
          profilePictureUrl: profilePictureUrl,
          userName: userName,
          description: description,
        ),
      ),
    );
  }

  Widget body() {
    return SliverList(
      delegate: SliverChildListDelegate([topTrack(), topArtist()]),
    );
  }

  Widget topTrack() {
    int counter = 0;
    return LimitedBox(
      maxHeight: 400,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "Top Tracks",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: topTracks.map((trackData) {
                        var totalItem = topTracks.length;
                        double rightMargin = (counter != totalItem - 1) ? 10 : 0;
                        counter++;

                        return Container(
                          margin: EdgeInsets.only(right: rightMargin),
                          child: topTrackItem(trackData),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topArtist() {
    int counter = 0;
    return LimitedBox(
      maxHeight: 400,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "Top Tracks",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: topTracks.map(
                        (trackData) {
                          var totalItem = topTracks.length;
                          double rightMargin = (counter != totalItem - 1) ? 10 : 0;
                          counter++;

                          return Container(
                            margin: EdgeInsets.only(right: rightMargin),
                            child: topTrackItem(trackData),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topTrackItem(Map<String, dynamic> trackData) {
    var trackCoverUrl = (trackData["album"]["images"] as List).length > 0
        ? trackData["album"]["images"][1]["url"]
        : null;

    Widget trackCover;
    if (trackCoverUrl != null) {
      trackCover = Container(
        height: 150,
        width: 150,
        child: Image.network(trackCoverUrl),
      );
    } else {
      trackCover = emptyCover();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              trackCover,
              Container(
                  height: 25,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trackData["name"],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                  height: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trackData["artists"][0]["name"],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(fontSize: 15),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget emptyCover() {
    return Placeholder();
  }

  Widget emptyProfile() {
    return Container(
      child: CircularProgressIndicator(),
      alignment: Alignment.center,
    );
  }
}
