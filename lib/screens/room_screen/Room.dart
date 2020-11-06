import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RoomPageState();
  }
}

class _RoomPageState extends State<RoomPage> {
  bool showTextInput = false;
  FocusNode f = new FocusNode();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: roomPageBody(),
    );
  }

  Widget roomPageBody() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: getChildren(),
      ),
    );
  }
  

  List<Widget> getChildren() {
    if (showTextInput) {
      return [

        Expanded(flex: 8, child: chatBody()),
        Divider(
          thickness: 2,
          height: 15,
        ),
        actionBar(),
        Divider(
          thickness: 2,
          height: 15,

        ),
        textInput(),
        Divider(
          thickness: 0,
          height: 7.5,

        )
      ];
    } else {
      return [
        Expanded(flex: 8, child: chatBody()),
        Divider(
          thickness: 2,
          height: 15,

        ),
        actionBar(),
        Divider(
          thickness: 0,
          height: 7.5,

        )
      ];
    }
  }

  Widget chatBody() {
    return FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ), // Color(0xFF161617),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text("not implemented yet"),
        ),
      ),
    );
  }

  Widget actionBar() {
    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Container(
      //  margin: EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                      icon: Icon(
                        Icons.music_note,
                        color: Colors.white,
                      ),
                      onPressed: null,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: null),
                  ),
                  Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                        icon: Icon(
                          Icons.mood,
                          color: Colors.white,
                        ),
                        onPressed: null),
                  ),
                  Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                        icon: Icon(
                          Icons.textsms,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            showTextInput = !showTextInput;
                          });
                        }),
                  ),
                ],
              ),
            ),
            /*Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              margin: EdgeInsets.only(bottom: 5),
              height: 5,
            )*/
          ],
        ),
      ),
    );
  }

  Widget textInput() {
    f.addListener(() {
      if (!f.hasFocus) {
        setState(() {
          showTextInput = !showTextInput;
        });
      }
    });
    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(style: BorderStyle.none),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            //  boxShadow: kElevationToShadow[3]
          ),
          child: TextField(
            decoration: InputDecoration(border: InputBorder.none),
            focusNode: f,
            scrollController: new ScrollController(),
            maxLines: 3,
            minLines: 1,
            autofocus: true,
          )),
    );
  }
}
