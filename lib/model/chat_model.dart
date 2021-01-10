import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/chat_controller.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/user_model.dart';

class ChatModel {
  final String chatID;
  Map<String, dynamic> chatData;
  Map<String, dynamic> _chatMessages = Map();
  Map<String, UserModel> chatMember = Map();
  Map<String, UserModel> nonChatMember = Map();
  final Stream<Event> chatStream;
  final FirebaseDatabase db;
  final String userID;

  int unReadMessages = 0;

  // ignore: close_sinks
  SingleSCMultipleSubscriptions<Map<String, dynamic>> chatDataStreamController =
      SingleSCMultipleSubscriptions();

  SingleSCMultipleSubscriptions<Map<String, dynamic>> chatMessageStreamController =
      SingleSCMultipleSubscriptions();

  SingleSCMultipleSubscriptions<Map<String, UserModel>> chatMemberStreamController =
      SingleSCMultipleSubscriptions();

  Stream<Event> chatEventStream;
  final Stream<Event> chatMemberEventStream;

  ChatModel(
    this.chatID,
    this.chatData,
    this.chatStream,
    this.chatMemberEventStream,
    this.db,
    this.userID,
  ) {
    loadChat(chatID);
    loadChatMember();
  }

  loadChat(String chatID) {
    chatStream.listen((chatEvent) {
      print("chatEvent");
      print(chatEvent.snapshot.value);
      chatData = Map.from(chatEvent.snapshot.value);
      chatDataStreamController.controller.add(chatData);
    });
  }

  loadChatMember() {
    chatMemberEventStream.listen((event) async {
      var userID = event.snapshot.value;
      var user = await App.getInstance().userProfileController.getUser(userID);
      chatMember[userID] = user;
      chatMemberStreamController.controller.add(chatMember);
      nonChatMember.remove(userID);
    });
    getNonChatMember();
  }

  loadChatContent() {
    if (chatEventStream == null) {
      chatEventStream = db.reference().child("chat_messages").child(chatID).onChildAdded;
      chatEventStream.listen((chatMessageEvent) {
        print("new message");
        var msgID = chatMessageEvent.snapshot.key;
        var msg = chatMessageEvent.snapshot.value as Map<dynamic, dynamic>;

        _chatMessages[msgID] = msg.cast<String, dynamic>();
        chatMessageStreamController.controller.add(_chatMessages);
        print("new message 2");
      });
    }
  }

  getChatMember() {}

  getNonChatMember() {
    App.getInstance().userProfileController.friendsStream.getStream().listen((friends) {
      var friendIDs = friends.keys.toList();
      friendIDs.forEach((id) {
        if (!chatMember.containsKey(id)) {
          nonChatMember[id] = friends[id];
        }
      });
    });
  }

  addMembers(List<String> members) {
    for (int i = 0; i < members.length; i++) {
      var memberID = members[i];

      db.reference().child("chats").child(chatID).child("members").push().set(memberID);
      db
          .reference()
          .child("users")
          .child(memberID)
          .child("chats")
          .child(chatID)
          .set({"mine": false});
    }
  }

  dispatchNotification(MsgType msgType, String msgID) {
    chatMember.forEach((key, user) {
      if (key != userID) {
        db.reference().child("users").child(user.userID).child("chat_notifications").push().set({
          "sender_id": App.getInstance().authorization.firebaseAuth.currentUser.uid,
          "msg_type": msgType.value,
          "msg_id": msgID,
          "seen": false
        });
      }
    });
  }

  void sendText(String chatID, String content, MsgType msgType) {
    print("TEST WEIRD BUG");
    print("sending msg...... to chat  " + chatID);

    var chatRef = db.reference().child("chat_messages").child(chatID);
    var newChatRef = chatRef.push();

    var chatData = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "content": content,
      "contentType": msgType.value,
      "senderID": userID,
      // TODO decide if we will use global variable or pass dependency
      "senderName": App.getInstance().authorization.userDisplayName,
      "chatID": newChatRef.key
    };

    newChatRef.set(chatData);
    dispatchNotification(msgType, newChatRef.key);
  }

  void sendMedia(String chatID, Map<String, dynamic> content, MsgType msgType) {
    print("sending media " + chatID);

    var chatRef = db.reference().child("chat_messages").child(chatID);
    var newChatRef = chatRef.push();

    var chatData = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "content": content,
      "contentType": msgType.value,
      "senderID": userID,
      "senderName": App.getInstance().authorization.userDisplayName,
      "chatID": newChatRef.key
    };

    newChatRef.set(chatData);
    dispatchNotification(msgType, newChatRef.key);
  }

  showGifPad() {
    // TODO should just request the ChatController object
    App.getInstance().roomController.channel.invokeListMethod("showGiphyPad", chatID);
  }
}
