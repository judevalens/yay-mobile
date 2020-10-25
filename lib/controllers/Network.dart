import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yay/controllers/App.dart';

import 'package:http/http.dart' as http;

class Network  extends ChangeNotifier{
  IO.Socket socket;
  String socketID;
  String userEmail;
  String activeRoomId;
  Map<String,dynamic> rooms = Map();
  HashSet<String> lastUpdatedRoom = HashSet();

  Network(){
    print("network");
    socket = IO.io("http://129.21.70.100:8000/socket.io/", <String, dynamic>{
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
      var config = {"socket_id": socketID, "user_email": App.getInstance().appSharedPreferences.get("userEmail")};
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

  Future<Map<String, dynamic>> queryWebApiWithToken (String endpoint, String accessToken) async {
    print("accesTOKEN " + accessToken);
    var result = await http.get(endpoint,
        headers: {
          "Authorization": "Bearer " + accessToken
        });

    return json.decode(result.body);
  }

  Future<Map<String, dynamic>> queryWebApi (String endpoint) async {
    return null;//queryWebApiWithToken(endpoint,App.getInstance().authorization.accessToken);
  }
}
