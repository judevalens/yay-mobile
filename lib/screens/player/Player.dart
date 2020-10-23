import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String imgSrc = "https://static.standard.co.uk/s3fs-public/thumbnails/image/2019/09/20/15/animalistic-imagery-runs-throughout-the-exhibition.jpg";
  Color controlsColor;

  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controlsColor = Theme.of(context).primaryColor;

    // TODO: implement build
    return Consumer<PlayBackState>(builder: (context, playBackState, child) {
      print("player is null");
      print(playBackState);
      return _buildPlayer(playBackState);
    });
  }

  Widget _buildPlayer(PlayBackState _playBackState) {
    print("current position " + _playBackState.playBackPosition.toString());
    print("duration pp" + _playBackState.track.toString());
    if (_playBackState.isUnAvailable) {
      return emptyPlayBackState();
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("music is playing: ${_playBackState.isPaused}"),
            artWork(),
            ChangeNotifierProvider.value(
              value: _playBackState,
              child: ProgressBar(
                height: 5,
              ),
            ),

            Row(
              children: [previousButton(),_playBackState.isPaused ? playButton() : pauseButton(),nextButton()],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        ),
      );
    }
  }

  Widget playButton() {
    return new IconButton(
          icon: new Icon(
            Icons.play_circle_outline,
            color: controlsColor,
          ),
          onPressed: null, iconSize: 65,);
  }

  Widget pauseButton() {
    return new IconButton(
        icon: new Icon(
          Icons.pause_circle_outline,
          color: controlsColor,
        ), onPressed: () {  }, iconSize: 65,
    );
  }
  Widget previousButton() {
    return new IconButton(
        icon: new Icon(
          Icons.skip_previous,
          color:controlsColor,
        ),
        onPressed: null, iconSize: 50,);

  }
  Widget nextButton() {
    return new IconButton(
        icon: new Icon(
          Icons.skip_next,
          color: controlsColor,
        ),
        onPressed: null, iconSize: 50,);
  }

  Widget emptyPlayBackState() {
    return Container(
      child: Text("no playback state yet"),
    );
  }
  
  Widget artWork(){
    return Container(child: Image.network(imgSrc),);
  }
}
