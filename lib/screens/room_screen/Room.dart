import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/ChatController.dart';
import 'package:yay/controllers/RoomController.dart';
import 'package:yay/misc/marquee/marquee.dart';
import 'file:///C:/Users/judev/Documents/flutter%20projects/yay-mobile/lib/screens/home_screen/RoomPlayerPage.dart';
import 'package:yay/screens/room_screen/Chat.dart';

class MyRoom extends StatefulWidget {
  final PageSwitcher pageSwitcher;
  final RoomController roomController;

  const MyRoom({Key key, this.pageSwitcher, this.roomController}) : super(key: key);

  @override
  _MyRoomState createState() => _MyRoomState();
}

class _MyRoomState extends State<MyRoom> with AutomaticKeepAliveClientMixin {
  FocusNode _focusNode = new FocusNode(canRequestFocus: false);
  double keyBoardHeight;
  double bottomPadding;
  bool isCustomKeyBoardOpen = false;
  OverlayEntry customKeyBoard;
  TextEditingController _textEditingController = new TextEditingController();

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

    if (!isCustomKeyBoardOpen) {
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
          Divider(height: 1,),
          bar(context, widget.pageSwitcher),
        ],
      ),
    );
  }

  Widget chatContainer() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Container(width: double.infinity, child: Chat()),
          ),
          topPlayer(context),
        ],
      ),
    );
  }

  Widget bar(BuildContext context, PageSwitcher pageSwitcher) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _focusNode.unfocus();
                pageSwitcher(0);
              },
              icon: Icon(Icons.arrow_upward_sharp),
            ),
          ),
          Expanded(
            child: TextField(

              decoration: InputDecoration(fillColor: Colors.black12, filled: true,hintText: "Say something...",hintStyle: Theme.of(context).primaryTextTheme.caption),
              focusNode: _focusNode,
              maxLines: 2,

              style: Theme.of(context).primaryTextTheme.bodyText1,
              minLines: 1,
              autofocus: false,
              textInputAction: TextInputAction.send,
              controller: _textEditingController,
              onSubmitted: (text) {
                print("sending chat " + text);
                _textEditingController.clear();
                widget.roomController.chatController
                    .sendText("",text, ChatItemType(ChatItemType.TEXT_CHAT));
                _focusNode.requestFocus();
              },
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {},
              icon: Icon(Icons.gif),
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _focusNode.unfocus();

                App.getInstance()
                    .roomController
                    .chatController
                    .channel
                    .invokeListMethod("showGiphyPad");
              },
              icon: Icon(Icons.emoji_emotions_sharp),
            ),
          ),
        ],
      ),
    );
  }

  Widget topPlayer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(1)),
        color: Theme.of(context).primaryColor,
      ),
      padding: EdgeInsets.all(5),
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
          return MMarqueeState(trackInfo, Theme.of(context).primaryTextTheme.bodyText2);
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
    Overlay.of(context).insert(customKeyBoard);
  }

  Widget buildCustomKeyBoard(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height - keyBoardHeight,
      child: SizedBox(
        height: keyBoardHeight,
        width: MediaQuery.of(context).size.width,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.deepOrange, border: Border.all(color: Colors.amber, width: 2)),
            child: MMarqueeState(
                "hello world hello worldhello worldhello worldhello worldhello worldhello world",
                Theme.of(context).primaryTextTheme.button)),
      ),
    );
  }
}
