import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/misc/marquee/marquee.dart';

import 'Player.dart';

typedef void goTo(int i);

class PlayerRoom extends StatefulWidget {
  @override
  _PlayerRoomState createState() => _PlayerRoomState();
}

class _PlayerRoomState extends State<PlayerRoom> {
  PageController _pageController = new PageController(keepPage: false);

  void goToPage(int i) {
    _pageController.animateToPage(i, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          ChangeNotifierProvider.value(
            value: App.getInstance().playBackController.currentPlayBackState,
            child: PlayerPage(
              pageSwitcher: goToPage,
            ),
          ),
          Container(
            height: double.infinity,
            color: Theme.of(context).backgroundColor,
            child: MyRoom(
              pageSwitcher: goToPage,
            ),
          ),
        ],
      ),
    );
  }
}

class MyRoom extends StatefulWidget {
  final goTo pageSwitcher;

  const MyRoom({Key key, this.pageSwitcher}) : super(key: key);

  @override
  _MyRoomState createState() => _MyRoomState();
}

class _MyRoomState extends State<MyRoom> with AutomaticKeepAliveClientMixin {
  FocusNode _focusNode = new FocusNode(canRequestFocus: false);
  double keyBoardHeight;
  double bottomPadding;
  bool isCustomKeyBoardOpen = false;
  OverlayEntry customKeyBoard;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("test 2");
    _focusNode.addListener(() {
      print(
          "Media query keyboard height is :" + MediaQuery.of(context).viewInsets.bottom.toString());
    });

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _focusNode.requestFocus();
    });

    //keyBoardHeight =  App.getInstance().appSharedPreferences.containsKey("keyBoardHeight") ? App.getInstance().appSharedPreferences.get("keyBoardHeight") :null;
    bottomPadding = 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("Media query keyboard height is :" + MediaQuery.of(context).viewInsets.bottom.toString());

    if (keyBoardHeight == null && MediaQuery.of(context).viewInsets.bottom > 50) {
      keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
      App.getInstance().appSharedPreferences.setDouble("keyBoardHeight", keyBoardHeight);
    }

    if(!isCustomKeyBoardOpen){
      bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    }

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: chatContainer()),
          bar(context, widget.pageSwitcher),
        ],
      ),
    );
  }

  Widget chatContainer() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: [
          topPlayer(),
          Expanded(child: chatList()),
        ],
      ),
    );
  }

  Widget bar(BuildContext context, goTo pageSwitcher) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                _focusNode.unfocus();
                pageSwitcher(0);
              },
              icon: Icon(Icons.arrow_upward_sharp),
            ),
          ),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              maxLines: 2,
              minLines: 1,
              autofocus: false,
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              icon: Icon(Icons.add_box_sharp),
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              icon: Icon(Icons.emoji_emotions_sharp),
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                //_focusNode.unfocus();

                App.getInstance().authorization.authenticationChannel.invokeListMethod("showGiphy");

              },
              icon: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatList() {
    return Container(
      child: ListView(),
    );
  }

  Widget topPlayer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(10),
      child: Row(children: [
        SizedBox(
          width: 64,
          height: 64,
          child: artWork(),
        ),
        Expanded(
            child: Container(
          child: trackInfo(),
        ))
      ]),
    );
  }

  Widget trackInfo() {
    return StreamBuilder(
        stream: App.getInstance().playBackController.sTrackNameStreamController.controller.stream,
        builder: (context, AsyncSnapshot<Tuple2<String, String>> snapShot) {
          String trackInfo = "No data";
          if (snapShot.hasData) {
            trackInfo = "Jude is playing " + snapShot.data.item1;
          }
          return MMarqueeState(trackInfo, Theme.of(context).accentTextTheme.bodyText1);
        });
  }

  Widget artWork() {
    return StreamBuilder(
      stream: App.getInstance().playBackController.sTrackCoverStreamController.getStream(),
      builder: (_, AsyncSnapshot<Uint8List> snapShot) {
        Widget image;
        if (snapShot.hasData) {
          image = Image.memory(snapShot.data);
        } else {
          image = Placeholder();
        }
        return AnimatedSwitcher(
            key: ValueKey(image.hashCode),
            duration: Duration(milliseconds: 100),
            child: Container(
              key: ValueKey(image.hashCode),
              child: image,
            ));
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void showKeyBoard(BuildContext context) {
    _focusNode.unfocus();
    isCustomKeyBoardOpen = true;
    customKeyBoard = OverlayEntry(
      builder: (context) {
        return buildCustomKeyBoard(context);
      },
    );
    Overlay.of(context).insert(
        customKeyBoard
    );
  }

  Widget buildCustomKeyBoard(BuildContext context){
    return Positioned(
      top:    MediaQuery.of(context).size.height-keyBoardHeight,
      child: SizedBox(
        height: keyBoardHeight,
        width: MediaQuery.of(context).size.width,
        child: Container(decoration: BoxDecoration(
            color: Colors.deepOrange,
            border: Border.all(color: Colors.amber, width: 2)
        ), child: MMarqueeState( "hello world hello worldhello worldhello worldhello worldhello worldhello world",Theme.of(context).primaryTextTheme.button)),
      ),
    );
  }
}
