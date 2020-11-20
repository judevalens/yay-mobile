import 'package:flutter/material.dart';
import 'package:yay/screens/rooms_screen/room_item.dart';

class RoomBottomSheet extends StatefulWidget {
  final double statusBarHeight;

  const RoomBottomSheet({Key key, this.statusBarHeight}) : super(key: key);

  @override
  _RoomBottomSheetState createState() => _RoomBottomSheetState();
}

class _RoomBottomSheetState extends State<RoomBottomSheet> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          widget.statusBarHeight,
      padding: EdgeInsets.only(left: 10, right: 10, top: widget.statusBarHeight),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded), onPressed: null),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Room",
                  style: Theme.of(context).accentTextTheme.headline4,
                ),
              ),
            ],
          ),
          Divider(),
          TabBar(
            controller: _tabController,
            tabs: [Text("Current room"), Text("My rooms")],
            labelStyle: Theme.of(context).primaryTextTheme.headline5,
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: TabBarView(controller: _tabController, children: [myCurrentRoom(), myRooms()]),
            ),
          )
        ],
      ),
    );
  }

  Widget myCurrentRoom() {
    return Container(
      child: Text("My current rooms"),
    );
  }

  Widget myRooms() {
    return Container(
      child: Text("My rooms"),
    );
  }

  Widget buildRoomList(BuildContext context,AsyncSnapshot snapshot) {
    Widget w;
    if(snapshot.hasData){
      var rooms = snapshot.data as Map<String,dynamic>;
      List<Widget> roomItems = new List();
      print("roomSize");
     // print(widget.roomController.myRooms.length);
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

}



