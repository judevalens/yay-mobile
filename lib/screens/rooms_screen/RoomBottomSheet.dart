import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/rooms_screen/room_item.dart';

class RoomBottomSheet extends StatefulWidget {
  final double statusBarHeight;

  const RoomBottomSheet({Key key, this.statusBarHeight}) : super(key: key);

  @override
  _RoomBottomSheetState createState() => _RoomBottomSheetState();
}

class _RoomBottomSheetState extends State<RoomBottomSheet>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          widget.statusBarHeight,
      padding: EdgeInsets.only(
        top: widget.statusBarHeight,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
      ),
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
              child:
                  TabBarView(controller: _tabController, children: [myCurrentRoom(), _RoomList()]),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class _RoomList extends StatefulWidget {
  @override
  __RoomListState createState() => __RoomListState();
}

class __RoomListState extends State<_RoomList> with AutomaticKeepAliveClientMixin {
  Stream<Map<String, dynamic>> roomListStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomListStream = App.getInstance().roomController.myRoomsStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: MediaQuery.of(context).viewInsets,
        child: buildRoomList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addRoomModalSheet(context);
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget buildRoomList() {
    return StreamBuilder(
        stream: roomListStream,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          Widget w;
          if (snapshot.hasData) {
            var rooms = snapshot.data;
            List<Widget> roomItems = new List();
            print("roomSize");
            // print(widget.roomController.myRooms.length);
            rooms.forEach((key, value) {
              print("myROom " + key);
              roomItems.add(new RoomItem(value));
            });

            w = new ListView(
              children: roomItems,
              shrinkWrap: false,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            );
          } else {
            w = Container(
              alignment: Alignment.center,
              height: double.infinity,
              child: Text("No room. Create one :)",style: TextStyle(color: Colors.black),),
            );
          }
          return w;
        });
  }

  Future<void> addRoomModalSheet(BuildContext context) {
    String joinCode = "";
    String roomName = "";
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1,
          widthFactor: 0.5,
          child: Container(
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Add/Join a room",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                Divider(
                  thickness: 2,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Enter Join Code"),
                  onChanged: (code) {
                    joinCode = code;
                  },
                ),
                Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Theme.of(context).primaryColor)),
                      onPressed: () {
                        App.getInstance().roomController.joinRoom(joinCode);
                      },
                      child: Text("Join room"),
                    )),
                Divider(
                  thickness: 2,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Enter a name"),
                  onChanged: (name) {
                    roomName = name;
                  },
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Theme.of(context).primaryColor)),
                    onPressed: () {
                      App.getInstance().roomController.createRoom(roomName);
                    },
                    child: Text("Create room"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
