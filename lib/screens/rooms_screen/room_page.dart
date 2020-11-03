import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/Network.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/RoomController.dart';
import 'package:yay/screens/rooms_screen/room_item.dart';

class RoomListPage extends StatefulWidget {
 final RoomController roomController;
  RoomListPage(this.roomController);
  @override
  _RoomListPageState createState() => _RoomListPageState();
}

typedef void SetExpanded(String key);


class _RoomListPageState extends State<RoomListPage> with AutomaticKeepAliveClientMixin {
  int roomJoinCode = 0;
  Map<String, Widget> rooms = Map();
  Stream<Map<String,dynamic>> roomListStream;

  RoomItem expandedRoomItem;
  SetExpanded toggle;
_RoomListPageState(){

}

  StreamController<Tuple2<bool,String>> _expandedWidgetState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomListStream = widget.roomController.myRoomsStream();
    print("init roomPage");
    _expandedWidgetState = new StreamController.broadcast();
    toggle = (String key){
      print("key " + key);
      _expandedWidgetState.add(new Tuple2(true, key));
    };
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).backgroundColor),
      alignment: Alignment.center,
      width: double.infinity,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: StreamBuilder(builder: buildRoomList, stream: roomListStream)
      )



    );
  }


  Stream<Tuple2> getExpandedWidgetStream(){
    return _expandedWidgetState.stream;
  }





  Widget buildRoomList(BuildContext context,AsyncSnapshot snapshot) {
    Widget w;
    if(snapshot.hasData){
      var rooms = snapshot.data as Map<String,dynamic>;
      List<Widget> roomItems = new List();
      print("roomSize");
          print(widget.roomController.myRooms.length);
      rooms.forEach((key, value) {
              print("myROom " + key);
              roomItems.add(new RoomItem(value));
      });

      w  = new ListView(
        children: roomItems,
        shrinkWrap: false,
        padding: EdgeInsets.fromLTRB(0,0,0,10),
      );
    }else{
      w  = Container(
        height: double.infinity,
        child: new CircularProgressIndicator(),
      );
    }
    return w;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _expandedWidgetState.close();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
