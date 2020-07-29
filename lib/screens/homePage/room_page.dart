import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yay/controllers/SpotifyApi.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int roomJoinCode = 0;

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
          RaisedButton(child: Text("create room"), onPressed: () {}),
        ],
      );
    });
  }
}
