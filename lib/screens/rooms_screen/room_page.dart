import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/Network.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/rooms_screen/room_item.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int roomJoinCode = 0;
  Map<String, Widget> rooms = Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpotifyApi>(builder: (context, spotifyApi, child) {
      print("stateChanged");
      return Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.number,
            onSubmitted: (value) => roomJoinCode = int.parse(value),
          ),
          RaisedButton(child: Text("join room"), onPressed: () {}),
          RaisedButton(
              child: Text("create room"),
              onPressed: () {
                spotifyApi.nt.socket.emit("create_room", {
                  "user_email": spotifyApi.userEmail,
                  "socket_id": spotifyApi.nt.socketID
                });
              }),
          Expanded(
            child: buildRoomList(),
          )
        ],
      );
    });
  }

  Widget buildRoomList() {

    return Selector<Network, Tuple2<Map<String, dynamic>, HashSet>>(
        selector: (buildContext, network) {
      return Tuple2(network.rooms, network.lastUpdatedRoom);
    }, builder: (ctx, data, child) {
      data.item2.forEach((element) {
        var roomData = data.item1[element];
        print("roomData");
        print(roomData);
        rooms[element] = RoomItem(roomData);
      });

      var roomList = List<Widget>();
      rooms.forEach((key, value) {
        roomList.add(value);
      });
      return ListView(
        children: roomList,
      );
    });
  }
}
