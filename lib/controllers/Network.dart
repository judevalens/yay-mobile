import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yay/controllers/SpotifyApi.dart';

class Network  extends ChangeNotifier{
  IO.Socket socket;
  String socketID;
  String userEmail;
  String activeRoomId;
  Map<String,dynamic> rooms = Map();
  HashSet<String> lastUpdatedRoom = HashSet();

  Network(){
    print("network");
    socket = IO.io("http://129.21.69.190:5000", <String, dynamic>{
      "transports": ["websocket"],
      "user_id": 'sknjssjsksksks',
      'autoConnect': false,
    });
    socketListener();
  }



  void socketListener() {
    socket.on('connect', (_) {
      print('connect to socket');
      socket.emit('msg', 'test');
    });

    socket.on("connection_config", (connectionConfig) {
      socketID = connectionConfig["socket_id"];
      var config = {"socket_id": socketID, "user_email": SpotifyApi.getInstance().appSharedPreferences.get("userEmail")};
        print("rcc");
      socket.emit("login", config);
    });

    socket.on("update_room_list", (roomList) {

      print("roomList");
      print(roomList);
      print(jsonDecode(roomList));
      print(jsonDecode(roomList).runtimeType);
      List<Map<String,dynamic>> roomListJson = jsonDecode(roomList).cast<Map<String,dynamic>>();



      roomListJson.forEach((element) {
        rooms.update(element["_id"]["\$oid"], (value) => element, ifAbsent: () => rooms.putIfAbsent(element["_id"]["\$oid"], () => element));
        lastUpdatedRoom.add(element["_id"]["\$oid"]);
      });

      print(roomListJson);
      print(roomListJson.runtimeType);

      print(rooms);
      

      notifyListeners();

    });
  }
  
  void joinRoom(int joinCode){
    socket.emit("join_room ");
  }
}
