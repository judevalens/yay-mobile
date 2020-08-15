import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yay/controllers/SpotifyApi.dart';
import 'package:yay/screens/player/progressBarPainter.dart';

import '';
import 'ProgressBar.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayerPageState();
  }
}

class PlayerPageState extends State<PlayerPage> {
  int playStatus = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<SpotifyApi>(builder: (context, spotifyApi, child) {
      print("player is null");
      print(spotifyApi);
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text("music is playing: ${spotifyApi.isPaused}"),
            RaisedButton(child: Text("play"), onPressed: () {}),
            RaisedButton(child: Text("pause"), onPressed: () {}),
            ChangeNotifierProvider.value(
              value: spotifyApi,
              child: ProgressBar(
                height: 40,
              ),
            )
          ],
        ),
      );
    });
  }
}
