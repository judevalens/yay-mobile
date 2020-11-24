import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';

import 'ChatItem.dart';

class Chat extends StatefulWidget {
  Chat():super(key: ValueKey("chat"));
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Map<String, ChatItem> chatItems = new Map();
  List<Map<String, dynamic>> chats = new List();
  ScrollController _scrollController = new ScrollController();
  Stream<List<Map<String, dynamic>>> chatStream =
      App.getInstance().roomController.chatController.messageStreamController.getStream();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("REBUILDING CHAT");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: chatStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> chatData) {
          Widget w;

          if (chatData.hasData) {
            chats = chatData.data;
          }

          print("chat data hashcode  " +  context.owner.toString());


          if (chats.length == 0) {
            w = Container(
              alignment: Alignment.center,
                child: Text(
              "Chat is empty",
              style: Theme.of(context).primaryTextTheme.bodyText1,
            ));
          }else{
            w = ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(left: 5, right: 5),
                physics: ClampingScrollPhysics(),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return ChatItem(chat: chats[index],key: ValueKey(chats[index]["chatID"]),scrollController: _scrollController,);
                });
          }


          if (App.getInstance().roomController.chatController.messageStreamController.brandNew){
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 900),
                curve: Curves.decelerate,
              );
            });
            App.getInstance().roomController.chatController.messageStreamController.brandNew = false;
          }




          return w;
        });
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }
}
