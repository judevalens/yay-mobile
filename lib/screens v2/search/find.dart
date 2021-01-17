import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/LibraryController.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';
import 'package:yay/screens%20v2/search/music.dart';
import 'package:yay/screens%20v2/search/people.dart';

class Find extends StatefulWidget {
  final FocusNode focusNode;

  const Find({Key key, this.focusNode}) : super(key: key);

  @override
  _FindState createState() => _FindState();
}

class _FindState extends State<Find> with TickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  double statusBarHeight;
  MusicPage _musicPage = MusicPage();
  PeoplePage _peoplePage = PeoplePage();
  FocusNode searchFocus = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        centerTitle: true,
        title: searchBar(),
      ),
      body: resultContainer(),
    );
  }

  Widget searchBar() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                controller:_textEditingController ,
                focusNode: widget.focusNode,
                onEditingComplete: () {
                  print("editing is done");
                },
                autofocus: false,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 15),
                expands: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    color: Colors.black,
                    onPressed: (){
                      _textEditingController.clear();
                    },
                  ),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(35),borderSide: BorderSide.none),
                  hintText: "Search for a song ",
                ),
                onChanged: (text) {
                  App.getInstance().browserController.search(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultContainer() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: searchResultList(context),
    );
  }

  Widget searchResultList(BuildContext context) {
    return StreamBuilder(
        stream: App.getInstance().browserController.newSearchResult.stream,
        builder: (context, AsyncSnapshot<CompositeSearchResult> searchResult) {
          Widget w;

          if (searchResult.hasData) {
            var compositeResult = searchResult.data;

            List<Widget> items = List.empty(growable: true);

            compositeResult.solvedCategories.forEach((category) {
              switch (category.type) {
                case "song":
                  items.add(Text(
                    "Songs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var songResult = App.getInstance().browserController.songSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(songResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
                case "artist":
                  items.add(Text(
                    "Artists",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var artistResult = App.getInstance().browserController.artistSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(artistResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
                case "user":
                  items.add(Text(
                    "Users",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var userResult = App.getInstance().browserController.userSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(userResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
              }
            });

            return ListView(
              key: UniqueKey(),
              addAutomaticKeepAlives: false,
              physics: BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
              children: items,
            );
          }
          return Text("No result");
        });
  }


}

class SearchResponseItem extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final FocusNode searchBarFocusNode;
  final String resultType;

  SearchResponseItem(this.resultData, this.searchBarFocusNode, this.resultType)
      : super(key: ValueKey(resultData));

  @override
  _SearchResponseItemState createState() => _SearchResponseItemState();
}

class _SearchResponseItemState extends State<SearchResponseItem> {
  int imagesListLength;
  String artistList;
  String name;
  String profileUrl;
  String id;

  @override
  void initState() {
    super.initState();

    switch (widget.resultType) {
      case "song":
        initSongResult();
        break;
      case "artist":
        initArtistsResult();
        break;
      case "user":
        initUserResult();
        break;
    }

    // TODO: implement initState
  }

  initSongResult() {
    imagesListLength = widget.resultData["album"]["images"].length;
    profileUrl = widget.resultData["album"]["images"][1]["url"];
    artistList = "";
    int counter = 0;
    for (var value in widget.resultData["artists"]) {
      artistList += value["name"];

      counter++;

      if (counter < widget.resultData["artists"].length) {
        artistList += ", ";
      }
    }
  }

  initArtistsResult() {
    var artistImage = (widget.resultData["images"] as List);
    profileUrl = artistImage.length > 0 ? widget.resultData["images"][1]["url"] : null;
    name = widget.resultData["name"];
    id = widget.resultData["id"];
  }

  initUserResult() {
    profileUrl = widget.resultData["user_spotify_profile"];
    name = widget.resultData["spotify_name"];
    id = widget.resultData["user_id"];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          print("TAPPPEDD!");

          switch (widget.resultType) {
            case "song":
              App.getInstance().playBackController.start(widget.resultData["uri"]);
              break;
            case "artist":
              break;
            case "user":
              break;
            default:
          }
        },
        child: getItem(),
      ),
    );
  }

  Widget getItem() {
    switch (widget.resultType) {
      case "song":
        return buildSongItem();
        break;
      case "artist":
        return artistItem();
        break;
      case "user":
        return userItem();
        break;
      default:
        return Container();
    }
  }

  Widget buildSongItem() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: Image.network(profileUrl),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.resultData["name"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artistList,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ),
          trackMoreButton(context),
        ],
      ),
    );
  }

  Widget trackMoreButton(BuildContext context) {
    return PopupMenuButton<int>(
      // padding: MediaQuery.of(context).viewInsets,
      onCanceled: () {
        widget.searchBarFocusNode.unfocus();
        //FocusScope.of(context).unfocus();
        ///// searchFocus.unfocus();
      },
      onSelected: (value) {
        if (value == 2) {
          /*App.getInstance()
              .roomController
              .chatController
              .sendMedia("",widget.track, MsgType(MsgType.SUGGESTION));*/
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
            child: Text("Play"),
            value: 0,
          ),
          const PopupMenuItem<int>(
            child: Text("add to queue"),
            value: 1,
          ),
          const PopupMenuItem<int>(
            child: Text("Suggest to room"),
            value: 2,
          ),
          const PopupMenuItem<int>(
            child: Text("Open in spotify"),
            value: 3,
          ),
        ];
      },
      icon: Icon(Icons.more_vert_sharp),
    );
  }

  Widget artistItem() {
    return GestureDetector(
      onTap: () {
        print("tapped artist");
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
              child: ClipOval(
                child: profileUrl != null
                    ? Image.network(
                        profileUrl,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        "assets/user.png",
                        fit: BoxFit.fill,
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

  Widget userItem() {
    return GestureDetector(
      onTap: () {
        print("tapped artist");
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return UserProfile(
            userID: id,
          );
        }));
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
              child: ClipOval(
                child: profileUrl != null
                    ? Image.network(
                        profileUrl,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        "assets/user.png",
                        fit: BoxFit.fill,
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
