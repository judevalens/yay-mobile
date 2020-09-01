import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yay/controllers/Network.dart';
import 'package:yay/controllers/SpotifyApi.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int roomJoinCode = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpotifyApi>(builder: (context, spotifyApi, child) {
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
        ],
      );
    });
  }
}

Widget buildRoomList(){
  return Selector<Network, List<Map<String,dynamic>>>(selector: (buildContext,network){
    return network.rooms;
  }, builder: (ctx, data, child){
    return Column;
  });
}
