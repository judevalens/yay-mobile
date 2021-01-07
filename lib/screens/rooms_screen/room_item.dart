import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/RoomController.dart';
import 'package:yay/screens/home_screen/home_page.dart';
import 'package:yay/screens/room_screen/Room.dart';

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
  RoomAction allowedAction;

  Map<String, dynamic> room;

  RoomItemState(this.room);

  Color arrowColor = Colors.white;
  bool _isExpanded = false;
  bool exclude = false;
  String textAction = "Join";

  bool isMyRoom = false;
  bool isActive = false;
  RoomController _roomController;
  SnackBar inActiveRoomSnackBar = SnackBar(content: Text("This room is inactive"));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _roomController = App.getInstance().roomController;

    allowedAction = _roomController.getAction(room["room_id"]);

    switch (allowedAction) {
      case RoomAction.JoinStream:
        textAction = "Join";
        isActive = true;
        break;
      case RoomAction.leaveStream:
        textAction = "Leave";
        break;
      case RoomAction.StartStream:
        textAction = "Start";
        break;
      case RoomAction.StopStream:
        textAction = "Stop";
        isActive = true;
        break;
      case RoomAction.RoomIsInactive:
        textAction = "Inactive";
        break;
    }
  }

/*

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
                //App.getInstance().roomController.
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).primaryColor)),
                  onPressed: () {
                /*
                    switch(allowedAction){
                      case RoomAction.JoinStream:
                        _roomController.joinStream(room["room_id"]);
                        break;
                      case RoomAction.leaveStream:
                        _roomController.leaveStream();
                        break;
                      case RoomAction.StartStream:
                        _roomController.streamToRoom(room["room_id"]);
                        break;
                      case RoomAction.StopStream:
                        _roomController.stopStreaming();
                        break;
                      case RoomAction.RoomIsInactive:
                        Scaffold.of(context).showSnackBar(inActiveRoomSnackBar);
                        break;
                    }
*/
                  if (allowedAction != RoomAction.RoomIsInactive){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return RoomPage();
                      }),
                    );
                  }
                  },
                  child: Text(textAction),
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
*/
  @override
  Widget build(BuildContext context) {
    return item(context);
  }

  Widget item(BuildContext context) {
    return Container(
      height: 130,
      child: Card(
        color: Theme.of(context).primaryColor,
        //shape: Recta(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [getTitleRow(context), actionBar(context)],
          ),
        ),
      ),
    );
  }

  void buttonAction() {}

  Widget getTitleRow(BuildContext context) {
    List<Widget> widgets = new List();

    widgets.add(Expanded(
      flex: 10,
      child: Text(
        room["room_name"],
        overflow: TextOverflow.fade,
        softWrap: false,
        style: Theme.of(context).primaryTextTheme.headline6,
      ),
    ));

    widgets.add(Spacer(
      flex: 1,
    ));

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      ),
    );
  }

  Widget actionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonBar(
          children: [
            TextButton(
              onPressed: () {

                  switch (allowedAction) {
                    case RoomAction.JoinStream:
                      _roomController.enterChat(room["room_id"]);
                      break;
                    case RoomAction.leaveStream:
                      _roomController.leaveStream();
                      break;
                    case RoomAction.StartStream:
                      _roomController.streamToRoom(room["room_id"]);
                      break;
                    case RoomAction.StopStream:
                      _roomController.stopStreaming();
                      break;
                    case RoomAction.RoomIsInactive:
                      Scaffold.of(context).showSnackBar(inActiveRoomSnackBar);
                      break;

                }
              },
              child: Text(
                textAction,
                style: Theme.of(context).primaryTextTheme.button,
              ),
            ),
            TextButton(

                onPressed: () => null,
                child: Text(
                  "Delete",
                  style: Theme.of(context).primaryTextTheme.button,
                ))
          ],
        )
      ],
    );
  }
}
