import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/chat_model.dart';

enum RoomAction { JoinStream, StartStream, StopStream, leaveStream, RoomIsInactive }

class MsgType {
  final String value;

  static const String TEXT_CHAT = "textChat";
  static const String TEXT = "text";
  static const String GIF = "gif";
  static const String STICKER = "sticker";
  static const String EMOJI = "emoji";
  static const String SUGGESTION = "suggestion";

  MsgType(this.value);
}

class ChatController extends ChangeNotifier {
  static const String startRoomUrl = "http://129.21.70.250:8000/startRoom";
  static const String MC_INSERT_MEDIA = "insertMedia";

  FirebaseDatabase _database;
  FirebaseFirestore _firestore;
  FirebaseAuth _auth;

  Map<String, dynamic> myRooms = new Map();
  StreamController<Map<String, dynamic>> list = new StreamController();
  SingleSCMultipleSubscriptions<Map<String, ChatModel>> roomListStreamController =
      new SingleSCMultipleSubscriptions();
  DatabaseReference currentRoom;

  // Used to set room inactive when room leader disconnect unexpectedly
  DatabaseReference currentRoomActiveState;
  String currentRoomID;
  OnDisconnect currentRoomOnDisconnect;
  StreamSubscription<Event> currentRoomPlayBackState;

  // room members subscribe to this stream
  StreamSubscription<Event> currentRoomState;
  String userID;
  bool isInRoom = false;
  bool isStreaming = false;

  bool isInitialized = false;

  ChatController chatController;

  SingleSCMultipleSubscriptions<Map<String, ChatModel>> sessionsListStream =
      new SingleSCMultipleSubscriptions();

  Map<String, ChatModel> chats = Map();
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
    var roomList = (await roomsRef.once()).value;
    // addRoom(roomList);

    roomsRef.onChildAdded.listen((event) {
      print("child added");

      var roomList = event.snapshot.value;
      var chatId = event.snapshot.key;
      Map<String, dynamic> chatData = Map.from(event.snapshot.value);
      print("chat data");
      print(chatData);
      //addNewRoom(event.snapshot.key);

      var chatStreamEvent = _database.reference().child("chats").child(chatId).onValue;
      var chatMemberEvent =
          _database.reference().child("chats").child(chatId).child("members").onChildAdded;
      chats[event.snapshot.key] = ChatModel(
          chatId, chatData, chatStreamEvent, chatMemberEvent, _database, _auth.currentUser.uid);
      sortedChats.remove(chatId);
      sortedChats.insert(0, chatId);
      roomListStreamController.controller.add(chats);
      // addRoom(roomList);
    });

    roomsRef.onChildChanged.listen((event) {
      print("child changed");
      print(roomList);
    });

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

  Future<void> createSession(String roomName) async {
    var joinCode = randomString(5);

    if (roomName.length == 0) {
      roomName = joinCode;
    }

    var roomRef = _database.reference().child("chats").push();

    var joinCodeRef = _database.reference().child("join_codes").child(joinCode);

    joinCodeRef.set(roomRef.key);

    roomRef.set({
      "chat_name": roomName,
      "chat_type": "group",
      "join_code": joinCode,
      "owner": _auth.currentUser.uid,
      "is_active": false,
      "play_back_state": {}
    });

    roomRef.child("members").push().set(_auth.currentUser.uid);

    // SAVE THIS ROOM FOR THE USER
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
    _database
        .reference()
        .child(_auth.currentUser.uid)
        .child("chat_notifications")
        .orderByKey()
        .onChildChanged
        .listen((chatNotificationEvent) {
      Map<String, dynamic> chatNotification = Map.from(chatNotificationEvent.snapshot.value);

      var chat = chats[chatNotification["chat_id"]];

      if (!chatNotification["seen"]) {
        chat.unReadMessages++;
        sortedChats.remove(chat.chatID);
        sortedChats.insert(0, chat.chatID);
      } else {
        chat.unReadMessages--;
      }
    });
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

  // determines the correct way to stop . stop stream or leave room;



  /// Stops streaming to a room

  /// Determine which action can be executed based on a room's state and a user's relation to the room
  ///
  /// [roomID].
  RoomAction getAction(String roomID) {
    var room = myRooms[roomID];

    print("room " + roomID);
    print(room);

    var isMyRoom = room["owner"] == App.getInstance().firebaseAuth.currentUser.uid;
    var isActive = room.containsKey("is_active") ? room["is_active"] : false;
    var action = isMyRoom ? RoomAction.StartStream : RoomAction.JoinStream;

    if (isMyRoom && isActive) {
      action = RoomAction.StopStream;
    } else if (isMyRoom && !isActive) {
      action = RoomAction.StartStream;
    } else if (!isMyRoom && isActive) {
      // if im in already in the room I can leave otherwise I can join the room!
      if (isInRoom && currentRoomID == roomID) {
        action = RoomAction.leaveStream;
      } else {
        action = RoomAction.JoinStream;
      }
    } else if (!isMyRoom && !isActive) {
      action = RoomAction.RoomIsInactive;
    }

    return action;
  }

  void addNewRoom(String roomID) async {
    var roomRef = _database.reference().child("chats").child(roomID);

    roomRef.onValue.listen((event) {
      print("child changed !!!");

      var roomValue = event.snapshot.value;
      Map<String, dynamic> myRoom = Map.from(roomValue);

      myRooms[roomID] = myRoom;

      list.add(myRooms);
      roomListStreamController.controller.add(myRooms);
    });
  }

  Future<void> addRooms(Map<dynamic, dynamic> roomList) async {
    if (roomList != null) {
      Map<String, dynamic> roomListMap = new Map.from(roomList);
      roomListMap.forEach((key, value) async {
        logger.d("key : " + key);
        var roomValue = (await _database.reference().child("rooms").child(key).once()).value;
        var roomKey = key;
        Map<String, dynamic> myRoom = Map.from(roomValue);
        myRooms[roomKey] = myRoom;

        logger.d("storing room with key :" + roomKey);
        logger.d(myRoom);
        list.add(myRooms);
      });
    }
  }





  String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      var charType = rand.nextInt(3);

      switch (charType) {
        case 0:
          return this.randomNumber();
          break;
        case 1:
          return this.randomLowerCase();
          break;
        case 2:
          return this.randomUpperCase();
          break;
      }
    });

    return new String.fromCharCodes(codeUnits);
  }

  int randomNumber() {
    var rand = new Random();
    return rand.nextInt(10) + 48;
  }

  int randomLowerCase() {
    var rand = new Random();
    return rand.nextInt(26) + 97;
  }

  int randomUpperCase() {
    var rand = new Random();
    return rand.nextInt(26) + 65;
  }
}