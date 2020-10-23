import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens/login_screen/login_screen.dart';

class Setting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingState();
  }
}

class SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new RaisedButton(
                child: new Text("Log out"),
                onPressed: () {
                  App.getInstance().authorization.logOut();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context) => LoginScreen()), (route) => false);
                }),
            new Text("The rest of this page is not implemented yet")
          ],
        ),
        alignment: Alignment.center,
      ),
    );
  }
}
