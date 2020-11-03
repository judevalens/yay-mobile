import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/room_screen/Room.dart';
import 'package:yay/screens/rooms_screen/room_page.dart';

class RoomItem extends StatefulWidget {
  final Map<String, dynamic> room;

  RoomItem(this.room) : super(key: PageStorageKey(UniqueKey()));

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RoomItemState(
      room,
    );
  }
}

class RoomItemState extends State<RoomItem> {
  String roomName;
  String roomId;
  bool isRoomActive;
  String ownerEmail;
  String activeRoomID;
  String roomAction;

  Map<String, dynamic> room;

  RoomItemState(this.room);

  Color arrowColor = Colors.white;
  bool _isExpanded = false;
  bool exclude = false;
  String test = "Join";

  bool isMyRoom = false;
  var isActive;
  String action;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isMyRoom = room["leader"] == App.getInstance().firebaseAuth.currentUser.uid;

    action = isMyRoom ? "Stream" : "Join";
    isActive = room.containsKey("is_active") ? room["is_active"] : false;
    if (isMyRoom && isActive) {
      action = "End Stream";
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print("width 10 " + MediaQuery.of(context).size.width.toString());
    return GestureDetector(
      child: Container(
        child: Card(
          color: Color(0xFF161617),
          elevation: 2,
          shape:
              Border.all(width: 0, color: Theme.of(context).accentColor, style: BorderStyle.none),
          child: Container(
            padding: EdgeInsets.all(10),
            child: ExpansionTile(
              maintainState: true,
              initiallyExpanded: false,
              title: getTitleRow(),
              expandedAlignment: Alignment.centerRight,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).accentColor)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return RoomPage();
                      }),
                    );
                  },
                  child: Text(action),
                ),
              ],
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitleRow() {
    if (!isActive) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 10,
            child: Text(
              room["room_id"],
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Spacer(
            flex: 2,
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 10,
            child: Text(
              room["room_id"],
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Icon(
            Icons.online_prediction,
            color: Colors.white,
          )
        ],
      );
    }
  }
}
