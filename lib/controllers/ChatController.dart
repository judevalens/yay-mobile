import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/RoomController.dart';
import 'package:yay/misc/SingleSubsStream.dart';

class ChatItemType {
  final String value;

  static const String TEXT_CHAT = "textChat";
  static const String TEXT = "text";
  static const String GIF = "gif";
  static const String STICKER = "sticker";
  static const String EMOJI = "emoji";
  static const String SUGGESTION = "suggestion";

  ChatItemType(this.value);
}

class ChatController {
  Logger logger = new Logger();

  static const String MC_INSERT_MEDIA = "insertMedia";

  final RoomController roomController;
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  List<Map<String, dynamic>> messages = new List();
  SingleSCMultipleSubscriptions<List<Map<String, dynamic>>> messageStreamController =
      new SingleSCMultipleSubscriptions();
  final MethodChannel channel = new MethodChannel(GIPHY_CHANNEL);
  static const String GIPHY_CHANNEL = "yay.homepage/giphy";
  DatabaseReference currentChatRef;
  StreamSubscription chatSubs;

  ChatController(this.roomController, this._auth, this._database) {
    channel.setMethodCallHandler((call) {
      if (call.method == MC_INSERT_MEDIA) {
        logger.i(call.arguments);


        var giphyData = jsonDecode(call.arguments);

        var giphySize = "downsized";

        if (giphyData["contentType"] == ChatItemType.EMOJI) {
          //giphySize = "original";
        }

        print("received gif");

        String chatID = giphyData["chat_id"];
        print("received gif  " +chatID );

        sendMedia(chatID, giphyData["media"]["images"][giphySize],
            ChatItemType(giphyData["contentType"]));
      }

      return;
    });
  }

  void loadChat() {
    messages.clear();

    currentChatRef =
        _database.reference().child("chatMessages").child(this.roomController.currentRoomID);

    chatSubs = currentChatRef.onChildAdded.listen((messageEvent) {
      Map<String, dynamic> messageData = Map.from(messageEvent.snapshot.value);

      messages.add(messageData);
      messageStreamController.brandNew = true;
      messageStreamController.controller.add(messages);
    });
  }

  void leaveChat() {
    messages.clear();
    chatSubs.cancel();
    messageStreamController.controller.add(messages);
  }

  void sendText(String chatID, String content, ChatItemType chatItemTYpe) {
    print("TEST WEIRD BUG");
    print("sending msg...... to chat  " + chatID);

    var chatRef = _database.reference().child("chat_messages").child(chatID);
    var newChatRef = chatRef.push();

    var chatData = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "content": content,
      "contentType": chatItemTYpe.value,
      "senderID": _auth.currentUser.uid,
      // TODO decide if we will use global variable or pass dependency
      "senderName": App.getInstance().authorization.userDisplayName,
      "chatID": newChatRef.key
    };

    newChatRef.set(chatData);
  }

  void sendMedia(String chatID, Map<String, dynamic> content, ChatItemType chatItemTYpe) {
    print("sending media " + chatID);


    var chatRef = _database.reference().child("chat_messages").child(chatID);
    var newChatRef = chatRef.push();

    var chatData = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "content": content,
      "contentType": chatItemTYpe.value,
      "senderID": _auth.currentUser.uid,
      "senderName": App.getInstance().authorization.userDisplayName,
      "chatID": newChatRef.key
    };

    newChatRef.set(chatData);
  }
}
