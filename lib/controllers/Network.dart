import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yay/controllers/SpotifyApi.dart';

class Network {
  IO.Socket socket;
  String socketID;
  String userEmail;
  List<Map<String,dynamic>> rooms =[];

  Network() {
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
      var roomListJson = jsonDecode(roomList);
      print(roomListJson);
      print(roomListJson.runtimeType);
      rooms.addAll(roomListJson.cast<Map<String,dynamic>>());

      print(rooms);
      


    });
  }
}
