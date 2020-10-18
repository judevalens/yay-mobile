import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/home_screen/home_page.dart';

class RoomItem extends StatefulWidget {
  final Map<String,dynamic> room;

  RoomItem(this.room);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RoomItemState(room);
  }
}

class RoomItemState extends State<RoomItem> {
  String roomName;
  String roomId;
  bool isRoomActive;
  String ownerEmail;
  String activeRoomID;
  String roomAction;

  Map<String,dynamic> room;

  RoomItemState(this.room);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                var items = List<Widget>();
                items.add(RaisedButton(
                  onPressed: () {},
                  child: Text("manage"),
                ));
                print("user email");
                print(App.getInstance().userEmail);
                print(ownerEmail);
                var actionText;
                if (room["owner"]["user_email"] == App.getInstance().userEmail) {


                  if (room["is_active"]) {
                    actionText = "Close room";
                    roomAction = "0";
                  } else {
                    actionText = "Start room";
                    roomAction = "start_room";
                  }
                } else {
                  if (room["is_active"]) {
                    if (!room["member"][App.getInstance().userEmail]["isActive"]) {
                      actionText = "Join room";
                      roomAction = "join_room";
                    } else {
                      actionText = "Leave room";
                      roomAction = "leave_room";
                    }
                  } else {
                    actionText = "Room is inactive";
                  }
                }

                items.add(
                  RaisedButton(
                    onPressed: () {

                    },
                    child: Text(actionText),
                  ),
                );
                return Container(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(12),
                          color: Colors.white,
                          child: Column(
                            children: items,
                          ),
                        )
                      ],
                    ));
              });
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.deepOrange,
              border: Border(bottom: BorderSide(color: Colors.white))),
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildItemRow(),
          ),
        ));
  }

  List<Widget> buildItemRow() {
    var items = List<Widget>();
    items.add(Text(
      "${room["join_code"]}",
      style: TextStyle(fontSize: 15, color: Colors.white),
    ));
    if (room["is_active"]) {
      items.add(Icon(
        Icons.fiber_manual_record,
        color: Colors.white,
      ));
    }

    return items;
  }
}
