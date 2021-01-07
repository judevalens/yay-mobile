import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:yay/misc/SingleSubsStream.dart';

class ChatModel {
  final String chatID;
  final Map<String, dynamic> _chatData;
  Map<String, dynamic> _chatMessages  = Map();
  Stream<Event> chatStream;
  final FirebaseDatabase db;

  // ignore: close_sinks
  SingleSCMultipleSubscriptions<Map<String, dynamic>> chatDataStreamController =
      SingleSCMultipleSubscriptions();

  SingleSCMultipleSubscriptions<Map<String, dynamic>> chatMessageStreamController =
      SingleSCMultipleSubscriptions();

  Stream<Event> chatEventStream;

  ChatModel(
    this.chatID,
    this._chatData,
    this.chatStream,
    this.db,
  ) {
    loadChat(chatID);
  }

  loadChat(String chatID) {
    chatStream.listen((chatEvent) {
      print("chatEvent");
      print(chatEvent.snapshot.value);
      Map<String, dynamic> _chatData = Map.from(chatEvent.snapshot.value);
      chatDataStreamController.controller.add(_chatData);
    });
  }

  loadChatContent() {
    if (chatEventStream == null) {
      chatEventStream = db.reference().child("chat_messages").child(chatID).onChildAdded;
      chatEventStream.listen((chatMessageEvent) {
        print("new message");
        var msgID = chatMessageEvent.snapshot.key;
        var msg = chatMessageEvent.snapshot.value as Map<dynamic,dynamic>;

        _chatMessages[msgID] = msg.cast<String,dynamic>();
        chatMessageStreamController.controller.add(_chatMessages);
        print("new message 2");

      });
    }
  }
}
