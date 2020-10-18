import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/play_back_state.dart';
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
    return Consumer<PlayBackState>(builder: (context, playBackState, child) {
      print("player is null");
      print(playBackState);
      return _buildPlayer(playBackState);
    });
  }

  Widget _buildPlayer(PlayBackState _playBackState){
    print("current position " + _playBackState.playBackPosition.toString());
    print("duration pp" + _playBackState.track.toString());
    if (_playBackState.isUnAvailable){
      return emptyPlayBackState();
    }else{
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text("music is playing: ${_playBackState.isPaused}"),
            RaisedButton(child: Text("play"), onPressed: () {}),
            RaisedButton(child: Text("pause"), onPressed: () {
              //  spotifyApi.disconnect();
            }),
            ChangeNotifierProvider.value(
              value: _playBackState,
              child: ProgressBar(
                height: 10,
              ),
            )
          ],
        ),
      );
    }



  }

  Widget emptyPlayBackState(){
    return Container(child: Text("no playback state yet"),);
  }
}
