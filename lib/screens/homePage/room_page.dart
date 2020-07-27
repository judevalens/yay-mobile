import 'package:flutter/material.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int roomJoinCode = 0;
  @override
  Widget build(BuildContext context) {
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
  }
}
