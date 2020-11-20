import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import "dart:math" as math;

class PlayListBottomSheet extends StatefulWidget {
  final double statusBarHeight;

  const PlayListBottomSheet({Key key, this.statusBarHeight});

  @override
  _PlayListBottomSheetState createState() => _PlayListBottomSheetState();
}

class _PlayListBottomSheetState extends State<PlayListBottomSheet> {
  PageController pageViewController = PageController(initialPage: 0);
  Widget currentWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 20),
      child: playListPage(),
    );
  }

  Widget individualPlayList() {
    return Container(
      child: Text("Individual playlist not implemented yet"),
    );
  }

  void viewIndividual() {
    setState(() {});
  }

  Widget playListPage() {
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          widget.statusBarHeight,
      padding: EdgeInsets.only(
        top: widget.statusBarHeight,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: [
            IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded), onPressed: null),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Playlists",
                style: Theme.of(context).accentTextTheme.headline4,
              ),
            ),
          ],
        ),
        Divider(),
        Expanded(child: playListBuilder()),
      ]),
    );
  }

  Widget playListBuilder() {
    return StreamBuilder(
        initialData: App.getInstance().browserController.playList,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> playlists) {
          Widget w;

          List<PlayListItem> playListItems = new List();

          playlists.data.forEach((playlist) {
            playListItems.add(PlayListItem(
              playlist: playlist,
              statusBarHeight: widget.statusBarHeight,
            ));
          });

          if (playListItems.length > 0) {
            w = new ListView(
              children: playListItems,
            );
          } else {
            w = Text("No playlist");
          }

          return w;
        });
  }
}

class PlayListItem extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final double statusBarHeight;

  PlayListItem({Key key, this.playlist, this.statusBarHeight}) : super(key: UniqueKey());

  @override
  _PlayListItemState createState() => _PlayListItemState();
}

class _PlayListItemState extends State<PlayListItem> {
  _PlayListItemState();

  @override
  Widget build(BuildContext context) {
    int imageLen = widget.playlist["images"].length;
    var imageIndex = math.min(imageLen, 2);
    var imageURL = imageLen > 0 ? widget.playlist["images"][imageIndex - 1]["url"] : null;

    ///print("image len " + imageLen.toString() + " imageIndex " + imageIndex.toString());
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        child: InkWell(
          onTap: () {
            goToSinglePage();
          },
          child: Container(
            child: SizedBox(
              height: 64,
              width: 64,
              child: Row(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    child: imageURL != null
                        ? Image.network(imageURL)
                        : Container(
                            color: Colors.amber,
                          ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 2),
                      child: Text(
                        widget.playlist["name"],
                        style: Theme.of(context).accentTextTheme.button,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.navigate_next_sharp),
                      onPressed: () {
                        goToSinglePage();
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goToSinglePage(){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (context) {
          return SinglePlayListPage(
            statusBarHeight: widget.statusBarHeight,
            playID: widget.playlist["id"],
            playlist: widget.playlist,
          );
        });
  }

}

class SinglePlayListPage extends StatefulWidget {
  final double statusBarHeight;
  final String playID;
  final Map<String, dynamic> playlist;

  const SinglePlayListPage({Key key, this.statusBarHeight, this.playID, this.playlist})
      : super(key: key);

  @override
  _SinglePlayListPageState createState() => _SinglePlayListPageState();
}

class _SinglePlayListPageState extends State<SinglePlayListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    App.getInstance().browserController.individualPlayList(widget.playID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          widget.statusBarHeight,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
      ),
      child: Column(children: [header(context), Divider(), Expanded(child: trackList())]),
    );
  }

  Widget header(BuildContext context) {
    int imageLen = widget.playlist["images"].length;
    var imageIndex = math.min(imageLen, 2);
    var imageURL = imageLen > 0 ? widget.playlist["images"][imageIndex - 1]["url"] : null;
    return Container(
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.only(top: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100, width: 100, child: Image.network(imageURL)),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist["name"],
                    style: Theme.of(context).primaryTextTheme.headline5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "by " + widget.playlist["owner"]["display_name"],
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget trackList() {
    return StreamBuilder(
        stream: App.getInstance().browserController.userIndividualPlayListStreamController.stream,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> playlist) {
          Widget w;
          List<PlayListTrackItem> playListTrackItem = new List();
          if (playlist.hasData) {
            print(playlist.data);

            List<Map<String, dynamic>> playListData = List.from(playlist.data["tracks"]["items"]);

            playListData.forEach((track) {
              playListTrackItem.add(PlayListTrackItem(
                track: track,
              ));
            });

            w = new ListView(
              children: playListTrackItem,
            );
          }
          if (playListTrackItem.length == 0) {
            w = Text("no data");
          }

          return w;
        });
  }
}

class PlayListTrackItem extends StatefulWidget {
  final Map<String, dynamic> track;
  final double statusBarHeight;

  PlayListTrackItem({Key key, this.track, this.statusBarHeight}) : super(key: UniqueKey());

  @override
  _PlayListTrackItemState createState() => _PlayListTrackItemState();
}

class _PlayListTrackItemState extends State<PlayListTrackItem> {
  _PlayListTrackItemState();

  @override
  Widget build(BuildContext context) {
    print("Album " + widget.track["track"]["album"].toString());

    int imageLen = widget.track["track"]["album"]["images"].length;
    var imageIndex = math.min(imageLen, 2);
    var imageURL =
        imageLen > 0 ? widget.track["track"]["album"]["images"][imageIndex - 1]["url"] : null;

    //print("image len " + imageLen.toString() + " imageIndex " + imageIndex.toString());
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        child: InkWell(
          onTap: () {
            App.getInstance().playBackController.start(widget.track["track"]["uri"]);
          },
          child: Container(
            child: SizedBox(
              height: 64,
              width: 64,
              child: Row(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    child: imageURL != null
                        ? Image.network(imageURL)
                        : Container(
                            color: Colors.amber,
                          ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 2),
                      child: Text(
                        widget.track["track"]["name"],
                        style: Theme.of(context).accentTextTheme.button,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.more_vert_sharp), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
