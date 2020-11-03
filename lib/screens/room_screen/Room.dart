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
      decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
      child:
      Column(
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
        Expanded(flex: 2,child: actionBar()),
        Expanded(flex: 2, child: textInput())
      ];
    } else {
      return [
        Expanded( flex: 7, child: chatBody()),
        Expanded( child: actionBar())
      ];
    }
  }

  Widget chatBody() {
    return FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 1,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            color: Colors.white, // Color(0xFF161617),
            boxShadow: kElevationToShadow[1],
            border: Border.all(width: 0.1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text("not implemented yet"),
        )

        ,
      ),
    );
  }

  Widget actionBar() {
    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Container(
        margin: EdgeInsets.all(2),
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
                boxShadow: kElevationToShadow[3],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.all(2),

                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                      icon: Icon(
                        Icons.music_note,
                        color: Colors.black54,
                      ),
                      onPressed: null,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(2),

                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(icon: Icon(Icons.add), onPressed: null),
                  ),
                  Container(
                    margin: EdgeInsets.all(2),

                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(icon: Icon(Icons.mood), onPressed: null),
                  ),
                  Container(
                    margin: EdgeInsets.all(1),

                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
                    child: IconButton(
                        icon: Icon(Icons.textsms),
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
      if (!f.hasFocus){
        setState(() {
          showTextInput = !showTextInput;

        });
      }
    });
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: TextField(
        focusNode: f,
        scrollController:  new ScrollController(),
        maxLines: 3,
        minLines: 1,
        autofocus: true,
      ),
    );
  }
}
