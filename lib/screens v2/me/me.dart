import 'package:flutter/material.dart';
import 'package:yay/screens/setting_screen/setting_screen.dart';

class Me extends StatefulWidget {
  @override
  _MeState createState() => _MeState();
}

class _MeState extends State<Me> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: MaterialButton(
        child: Icon(Icons.logout),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Setting();
              },
            ),
          );
        },
      ),
    );
  }
}
