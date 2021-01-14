import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/chat_model.dart';

enum StreamAction { JoinStream, StartStream, StopStream, leaveStream, RoomIsInactive }
enum StreamStatus { Idle, StreamProvider, StreamReceiver }

class MsgType {
  final String value;

  static const String TEXT_CHAT = "textChat";
  static const String TEXT = "text";
  static const String GIF = "gif";
  static const String STICKER = "sticker";
  static const String EMOJI = "emoji";
  static const String SUGGESTION = "suggestion";
  static const String NEW_CHAT = "new_chat";

  MsgType(this.value);
}

class ChatController extends ChangeNotifier {
  static const String startRoomUrl = "http://129.21.70.250:8000/startRoom";
  static const String MC_INSERT_MEDIA = "insertMedia";

  FirebaseDatabase _database;
  FirebaseFirestore _firestore;
  FirebaseAuth _auth;

  SingleSCMultipleSubscriptions<Map<String, ChatModel>> chatsStreamController =
      new SingleSCMultipleSubscriptions();
  DatabaseReference currentRoom;

  // Used to set room inactive when room leader disconnect unexpectedly
  DatabaseReference currentRoomActiveState;
  String currentRoomID;
  OnDisconnect currentRoomOnDisconnect;
  StreamSubscription<Event> currentRoomPlayBackState;
  Stream<Event> playBackEvent;

  // room members subscribe to this stream
  // ignore: cancel_subscriptions
  StreamSubscription<Event> currentChatStreamingState;
  String userID;
  bool isInRoom = false;
  bool isStreaming = false;
  StreamStatus streamStatus = StreamStatus.Idle;
  DatabaseReference streamStatusRef;

  String currentStreamID;
  bool isInitialized = false;

  ChatController chatController;

  SingleSCMultipleSubscriptions<Map<String, ChatModel>> sessionsListStream =
      new SingleSCMultipleSubscriptions();

  Map<String, ChatModel> chats = Map();
  Map<String, int> chatNotifications = Map();
  List<String> sortedChats = List.empty(growable: true);

  final MethodChannel channel = new MethodChannel(GIPHY_CHANNEL);
  static const String GIPHY_CHANNEL = "yay.homepage/giphy";

  ChatController(this._database, this._auth) {
    watchAuthorization();
  }

  void watchAuthorization() {
    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        if (!isInitialized) {
          init();
        }
      } else {
        if (isInitialized) {
          // shutdown();
        }
      }
    });
  }

  Logger logger = new Logger();

  Future<void> init() async {
    setUpGifReceiver();
    userID = _auth.currentUser.uid;

    var roomsRef = (_database
        .reference()
        .child("users")
        .child(_auth.currentUser.uid)
        .child("chats")
        .orderByKey());
    // addRoom(roomList);

    roomsRef.onChildAdded.listen((event) {
      print("child added");

      var roomList = event.snapshot.value;
      var chatId = event.snapshot.key;
      Map<String, dynamic> chatData = Map.from(event.snapshot.value);
      print("chat data");
      print(chatData);
      //addNewRoom(event.snapshot.key);

      var chatDataEvent = _database.reference().child("chats").child(chatId).onValue;
      var chatMemberEvent = _database
          .reference()
          .child("chats")
          .child(chatId)
          .child("members")
          .orderByChild("added")
          .onChildAdded;
      chats[event.snapshot.key] =
          ChatModel(chatId, chatDataEvent, chatMemberEvent, _database, _auth.currentUser.uid, this);
      if (!sortedChats.contains(chatId)) {
        sortedChats.add(chatId);
      }
      chatsStreamController.controller.add(chats);
      // addRoom(roomList);
    });

    roomsRef.onChildChanged.listen((event) {
      print("child changed");
    });

    loadNotification();

    roomsRef.onChildRemoved.listen((event) {
      var roomList = event.snapshot.value;
      // removeRoom(roomList);
    });
  }

  setUpGifReceiver() {
    channel.setMethodCallHandler((call) {
      if (call.method == MC_INSERT_MEDIA) {
        logger.i(call.arguments);

        var giphyData = jsonDecode(call.arguments);

        var giphySize = "downsized";

        if (giphyData["contentType"] == MsgType.EMOJI) {
          //giphySize = "original";
        }

        print("received gif");

        String chatID = giphyData["chat_id"];
        print("received gif  " + chatID);

        var chatModel = chats[chatID];

        chatModel.sendMedia(
            chatID, giphyData["media"]["images"][giphySize], MsgType(giphyData["contentType"]));
      }

      return;
    });
  }

  Future<void> createGroupChat(String roomName) async {
    var roomRef = _database.reference().child("chats").push();

    if (roomName.length == 0) {
      roomName = roomRef.key;
    }

    roomRef.set({
      "chat_name": roomName,
      "chat_type": "group",
      "owner": _auth.currentUser.uid,
      "is_active": false,
      "play_back_state": {},
      "is_streaming": false,
    });

    _database
        .reference()
        .child("chats")
        .child(roomRef.key)
        .child("members")
        .child(_auth.currentUser.uid)
        .set({
      "member_id": _auth.currentUser.uid,
      "added": DateTime.now().toUtc().millisecondsSinceEpoch
    });
    // SENDING NEW GROUP NOTIFICATIONS , so it can be push at the top
    _database
        .reference()
        .child("users")
        .child(_auth.currentUser.uid)
        .child("chat_notifications")
        .push()
        .set({
      "sender_id": App.getInstance().authorization.firebaseAuth.currentUser.uid,
      "msg_type": MsgType.NEW_CHAT,
      "msg_id": roomRef.key,
      "seen": true,
      "chat_id": roomRef.key
    });

    // save a ref of this chat for the owner
    _database
        .reference()
        .child("users")
        .child(_auth.currentUser.uid)
        .child("chats")
        .child(roomRef.key)
        .set({"mine": true});

    print("created room");
  }

  loadNotification() {
    print("loading notifications");
    _database
        .reference()
        .child("users")
        .child(_auth.currentUser.uid)
        .child("chat_notifications")
        .orderByKey()
        .onChildAdded
        .listen((chatNotificationEvent) {
      print("notif");
      Map<String, dynamic> chatNotification = Map.from(chatNotificationEvent.snapshot.value);
      var chatID = chatNotification["chat_id"];
      sortedChats.remove(chatID);
      sortedChats.insert(0, chatID);
      chatsStreamController.controller.add(chats);
      if (!chatNotification["seen"]) {
        if (chatNotifications.containsKey(chatID)) {
          chatNotifications[chatID]++;
        } else {
          chatNotifications[chatID] = 1;
        }
      }
    });

    _database
        .reference()
        .child("users")
        .child(_auth.currentUser.uid)
        .child("chat_notifications")
        .orderByKey()
        .onChildChanged
        .listen((chatNotificationEvent) {
      print("notif");
      Map<String, dynamic> chatNotification = Map.from(chatNotificationEvent.snapshot.value);

      var chatID = chatNotification["chat_id"];

      if (chatNotifications.containsKey(chatID)) {
        chatNotifications[chatID]++;
      } else {
        chatNotifications[chatID] = 1;
      }

      chatsStreamController.controller.add(chats);
    });
  }

  bool hasUnreadMessages(String chatID) {
    if (!chatNotifications.containsKey(chatID)) {
      return false;
    }
    return chatNotifications[chatID] > 0;
  }

  void clearNotification(String chatID) {
    if (chatNotifications.containsKey(chatID)) {
      chatNotifications[chatID] = 0;
      chatsStreamController.controller.add(chats);
    }
  }

  loadChat(String chatID) {
    _database
        .reference()
        .child("chats")
        .child(chatID)
        .orderByKey()
        .onChildAdded
        .listen((chatEvent) {
      chatEvent.snapshot.value;
    });
  }

  sync(String chatID) {
    var action = getAction(chatID);
    switch (action) {
      case StreamAction.JoinStream:
        joinStream(chatID);
        break;
      case StreamAction.StartStream:
        stream(chatID);
        break;
      case StreamAction.StopStream:
        stopStreaming();
        break;
      case StreamAction.leaveStream:
        leaveStream(chatID);
        break;
      case StreamAction.RoomIsInactive:
        // TODO: Handle this case.
        break;
    }
  }

  /// Determine which action can be executed based on a room's state and a user's relation to the room
  ///
  /// [chatID].
  StreamAction getAction(String chatID) {
    var chat = chats[chatID];

    print("chat owner");
    print(chat.chatOwnerID);

    if (chat.chatOwnerID == _auth.currentUser.uid) {
      if (chat.chatData["is_streaming"]) {
        return StreamAction.StopStream;
      } else if (!chat.chatData["is_streaming"]) {
        return StreamAction.StartStream;
      }
    } else {
      if (!chat.chatData["is_streaming"]) {
        return StreamAction.RoomIsInactive;
      }
      if (streamStatus == StreamStatus.StreamReceiver) {
        if (currentStreamID == chatID && chat.chatData["is_streaming"]) {
          return StreamAction.leaveStream;
        } else if (chat.chatData["is_streaming"]) {
          return StreamAction.JoinStream;
        }
      } else if (chat.chatData["is_streaming"]) {
        return StreamAction.JoinStream;
      }
    }
    return StreamAction.RoomIsInactive;
  }

  stream(String chatID) {
    if (streamStatus == StreamStatus.StreamProvider) {
      stopStreaming();
    } else if (streamStatus == StreamStatus.StreamReceiver) {
      leaveStream(chatID);
    }

    streamStatusRef = _database.reference().child("chats").child(chatID).child("is_streaming");
    streamStatusRef.set(true);
    streamStatusRef.onDisconnect().set(false);
    App.getInstance().playBackController.setCurrentMode(playerMode.STREAMING);
    currentStreamID = chatID;
    streamStatus = StreamStatus.StreamProvider;
  }

  joinStream(String chatID) {
    print("joining stream");
    if (streamStatus == StreamStatus.StreamProvider) {
      stopStreaming();
    } else if (streamStatus == StreamStatus.StreamReceiver) {
      leaveStream(chatID);
    }

    currentChatStreamingState = _database
        .reference()
        .child("chats")
        .child(chatID)
        .child("is_streaming")
        .onValue
        .listen((event) {
      var isStreaming = event.snapshot.value;
      if (!isStreaming) {
        leaveStream(chatID);
      }
    });

    streamStatusRef = _database
        .reference()
        .child("chats")
        .child(chatID)
        .child("members")
        .child(_auth.currentUser.uid);

    streamStatusRef.update({"stream_status": "receiving"});
    streamStatusRef.onDisconnect().update({"stream_status": "idle"});
    streamStatus = StreamStatus.StreamReceiver;
    currentStreamID = chatID;
    chats[chatID].chatStreamStatus.controller.add(true);
    syncPlayBack(chatID, true);
  }

  stopStreaming() {
    if (streamStatusRef != null) {
      currentStreamID = null;
      App.getInstance().playBackController.setCurrentMode(playerMode.NORMAL);
      streamStatusRef.set(false);
    }
  }

  leaveStream(String chatID) {
    if (streamStatusRef != null) {
      App.getInstance().playBackController.setCurrentMode(playerMode.NORMAL);
      streamStatusRef.update({"stream_status": "idle"});
      streamStatus = StreamStatus.Idle;
      currentStreamID = null;
      currentChatStreamingState.cancel();
      syncPlayBack(chatID, false);
    }
    chats[chatID].chatStreamStatus.controller.add(false);
  }

  streamPlayBack(dynamic playBackState) {
    if (currentStreamID != null) {
      _database
          .reference()
          .child("chats")
          .child(currentStreamID)
          .child("playback_state")
          .set(playBackState);
    }
  }

  syncPlayBack(String chatID, bool sync) {
    if (sync) {
      playBackEvent =
          _database.reference().child("chats").child(chatID).child("playback_state").onValue;
      currentRoomPlayBackState = playBackEvent.listen((event) {
        Map<String, dynamic> playState = Map.from(event.snapshot.value);
        var playStateToString = jsonEncode(playState);
        
        print("sync playback state  ");
        print(playState);
        App.getInstance().playBackController.sync(jsonDecode(playStateToString));
      });
    } else {
      if (playBackEvent != null) {
        playBackEvent = null;
        currentRoomPlayBackState.cancel();
      }
    }
  }
}