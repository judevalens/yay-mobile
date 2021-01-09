import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/ChatController.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/chat_model.dart';

enum RoomAction { JoinStream, StartStream, StopStream, leaveStream, RoomIsInactive }

class RoomController extends ChangeNotifier {
  static const String startRoomUrl = "http://129.21.70.250:8000/startRoom";

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

  Map<String,ChatModel> chats= Map();

  RoomController(this._database, this._auth) {
    watchAuthorization();
  }

  void watchAuthorization() {
    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        if (!isInitialized) {
          init();
          chatController = new ChatController(this, _auth, _database);
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
    userID = _auth.currentUser.uid;

    var roomsRef =
    (_database.reference().child("users").child(_auth.currentUser.uid).child("chats"));
    var roomList = (await roomsRef.once()).value;
    // addRoom(roomList);

    roomsRef.onChildAdded.listen((event) {
      print("child added");

      var roomList = event.snapshot.value;
      var chatId  = event.snapshot.key;
      Map<String, dynamic> chatData = Map.from(event.snapshot.value);
      print(roomList);
      //addNewRoom(event.snapshot.key);

      var chatStreamEvent = _database.reference().child("chats").child(chatId).onValue;
      chats[event.snapshot.key] = ChatModel(chatId,chatData,chatStreamEvent,_database);
      roomListStreamController.controller.add(chats);
      // addRoom(roomList);
    });

    roomsRef.onChildChanged.listen((event) {
      print("child changed");
      print(roomList);
    });

    roomsRef.onChildRemoved.listen((event) {
      var roomList = event.snapshot.value;
      removeRoom(roomList);
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

  Future<void> joinGroupChat(String joinCode) async {
    var joinCodeRef = _database.reference().child("join_codes").child(joinCode);
    dynamic roomID = (await joinCodeRef.once()).value;
    logger.d("joining room , roomID :" + (roomID == null).toString());
    if (roomID != null) {
      logger.d(roomID);
      var roomMembersRef = _database.reference().child("chats").child(roomID).child("members_id");

      var notInRoom =
          (await roomMembersRef.equalTo(null, key: _auth.currentUser.uid).once()).value == null;

      print("isInRoom");
      print(notInRoom);

      if (notInRoom) {
        roomMembersRef.child(_auth.currentUser.uid).set(true);
        _database
            .reference()
            .child("users")
            .child(_auth.currentUser.uid)
            .child("chats")
            .child(roomID)
            .set({"mine": false});
      }
    }
  }

  Future<bool> enterChat(String chatID) async {
    var chatToJoinRef = _database.reference().child("rooms").child(chatID);
    var chatToJoin = (await chatToJoinRef.once()).value;

    if (!chatToJoin["is_active"]) {
      return false;
    }
    // Before joining a new room, user must leave its current room if applicable
    if (isInRoom) {
      leaveStream();
    }

    currentRoom = _database.reference().child("chats").child(chatID);

    // member state ref
    var memberRef = currentRoom.child("members_id").child(userID);

    // let the room know when a member disconnect unexpectedly
    currentRoomOnDisconnect = memberRef.onDisconnect();
    currentRoomOnDisconnect.set(false);
    memberRef.set(true);
    currentRoomID = currentRoom.key;
    isInRoom = true;
    chatController.loadChat();
    // update the playback mode, so we can be in sync with the room
    await App.getInstance().playBackController.setCurrentMode(playerMode.LISTENING);

    // listening for play back state updates
    currentRoomPlayBackState = currentRoom.child("play_back_state").onValue.listen((event) {
      if (playerMode.LISTENING == App.getInstance().playBackController.currentMode) {
        Map<String, dynamic> leaderPlayBackState = Map.from(event.snapshot.value);
        // App.getInstance().playBackController.sync(leaderPlayBackState);
      }
    });

    // watch room state. when inactive  members shall stop listening for updates from this room.
    currentRoomState = currentRoom.child("is_active").onValue.listen((event) {
      var isActive = event.snapshot.value;
      if (!isActive) {
        leaveStream();
      }
    });

    return true;
  }

  loadChat(String chatID) {
    _database.reference().child("chats").child(chatID).orderByKey().onChildAdded.listen((chatEvent) {
      chatEvent.snapshot.value;
    });
  }



  // determines the correct way to stop . stop stream or leave room;
  void stop() {
    if (isStreaming) {
      stopStreaming();
    } else {
      leaveStream();
    }
  }

  void sendKeepAlive() {}
  void leaveStream() async {
    if (currentRoom != null) {
      currentRoom.child("members_id").child(userID).set(false);
      currentRoomID = null;
      isInRoom = false;
      currentRoomPlayBackState.cancel();
      currentRoomState.cancel();
      chatController.leaveChat();
      await App.getInstance().playBackController.setCurrentMode(playerMode.NORMAL);
    } else {
      logger.i("current room is null; can't leave stream");
    }
  }
  void streamToRoom(String roomID) async {
    if (isInRoom) {
      stop();
    }
    currentRoom = _database.reference().child("chats").child(roomID);
    currentRoomActiveState = currentRoom.child("is_active");

    // set is_active to false if roomLeader disconnect unexpectedly
    // this will close the room for all of the other members
    currentRoomOnDisconnect = currentRoomActiveState.onDisconnect();
    currentRoomOnDisconnect.set(false);
    currentRoom.child("is_active").set(true);

    currentRoomActiveState.onValue.listen((event) {
      logger.d("room status changes \n isActive " + event.snapshot.value.toString());
      var isActive = event.snapshot.value;
      if (!isActive) {
        stopStreaming();
      }
    });

    isInRoom = true;
    isStreaming = true;
    currentRoomID = currentRoom.key;
    chatController.loadChat();
    await App.getInstance().playBackController.setCurrentMode(playerMode.STREAMING);
    var currentPlayBackState = App.getInstance().playBackController.getPlayBackState();

    currentPlayBackState.then((_currentPlayBackState) {
      streamPlayBackState(_currentPlayBackState);
    });
  }

  /// Stops streaming to a room
  void stopStreaming() async {
    if (currentRoom != null) {
      logger.d("stopped streaming");
      currentRoom.child("is_active").set(false);
      isInRoom = false;
      isStreaming = false;
      chatController.leaveChat();
      await App.getInstance().playBackController.setCurrentMode(playerMode.NORMAL);
    } else {
      logger.i("current room is null; cant stop streaming");
    }
  }

  void streamPlayBackState(Map<String, dynamic> currentPlayBackState) {
    currentRoom.child("play_back_state").update(currentPlayBackState);
  }

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

  Stream<Event> getRoomStream() {
    return null;
  }


  void addNewRoom(String roomID) async {
    var roomRef = _database.reference().child("chats").child(roomID);

    roomRef.onValue.listen((event) {
      print("child changed !!!");

      var roomValue = event.snapshot.value;
      Map<String, dynamic> myRoom = Map.from(roomValue);

      myRooms[roomID] = myRoom;

      checkRoomState();

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

  void checkRoomState() {}

  void removeRoom(Map<dynamic, dynamic> roomList) async {}

  void updateRoom(Map<dynamic, dynamic> roomList) {}

  Stream getRoomListStream() {
    return list.stream.asBroadcastStream();
  }

  Stream<Map<String, dynamic>> myRoomsStream() {
    return roomListStreamController.getStream();
  }

  Future<void> listRoom(Map<dynamic, dynamic> roomsData) async {}

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