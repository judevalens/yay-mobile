import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';

class PeoplePage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> with TickerProviderStateMixin {
  TabController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(child: searchBar()),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: TabBar(
              onTap: (index) {
                print("TAPPED!! " + index.toString());
                setState(() {
                  currentIndex = index;
                });
              },
              controller: _controller,
              tabs: [
                Tab(
                  text: "Artist",
                ),
                Tab(
                  text: "Users",
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: [artistSearchResult(), userSearchResult()],
            ),
          )
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 5),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                onEditingComplete: () {
                  print("editing is done");
                },
                autofocus: false,
                cursorColor: Colors.black54,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search for an artist, a friend... ",
                ),
                onChanged: (text) {
                  App.getInstance().browserController.searchArtists(text);
                  App.getInstance().browserController.searchUsers(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget artistSearchResult() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: StreamBuilder(
        stream: App.getInstance().browserController.artistQueryResponseStreamController.stream,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            var artistData = snapshot.data;

            if (artistData.length == 0) {
              return emptyList();
            }

            return ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              key: UniqueKey(),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var artistImage = (artistData[index]["images"] as List);
                var profileUrl =
                    artistImage.length > 0 ? artistData[index]["images"][1]["url"] : null;
                var artistName = artistData[index]["name"];
                return artistItem(profileUrl, artistName);
              },
              itemCount: artistData.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            );
          } else {
            return emptyList();
          }
        },
      ),
    );
  }

  Widget userSearchResult() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: StreamBuilder(
        stream: App.getInstance().browserController.userQueryResponseStreamController.stream,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            var usersData = snapshot.data;

            if (usersData.length == 0) {
              return emptyList();
            }

            return ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              key: UniqueKey(),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var userData = usersData[index];

                var userProfile = userData["user_spotify_profile"];
                var userName = userData["spotify_name"];
                var userId = userData["user_id"];
                return userItem(userProfile, userName,userId);
              },
              itemCount: usersData.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            );
          } else {
            return emptyList();
          }
        },
      ),
    );
  }

  Widget emptyList() {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      child: Text("No result"),
    );
  }

  Widget artistItem(String profileUrl, String name) {
    return GestureDetector(
      onTap: () {
        print("tapped artist");

      },
      child: Container(
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: ClipOval(
                child: profileUrl != null
                    ? Image.network(
                  profileUrl,
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
  Widget userItem(String profileUrl, String name, String userID) {
    return GestureDetector(
      onTap: () {
        print("tapped artist");
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return UserProfile(userID: userID,);
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
                child: profileUrl != null
                    ? Image.network(
                  profileUrl,
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

}
