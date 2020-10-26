import 'dart:typed_data';

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
  String imgSrc =
      "https://static.standard.co.uk/s3fs-public/thumbnails/image/2019/09/20/15/animalistic-imagery-runs-throughout-the-exhibition.jpg";
  Color controlsColor;

  @override
  initState() {
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
        child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 1,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      child: _playBackState.coverImage == null
                          ? defaultCover()
                          : artWork(_playBackState.coverImage),
                    ),
                  ),
                ),
                Column(
                  children: [
                    ChangeNotifierProvider.value(
                      value: _playBackState,
                      child: ProgressBar(
                        height: 10,
                        seekCallBack: App.getInstance().playBackController.seek,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5 , 0, 0),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(positionFormatter(_playBackState.playBackPosition),style:
                          new TextStyle(color: Colors.white),),
                          Text(positionFormatter(_playBackState.track.duration),style:
                          new TextStyle(color: Colors.white),)
                        ],
                      ) ,
                    ),

                  ],
                ),
                Row(
                  children: [
                    previousButton(),
                    _playBackState.isPaused ? playButton() : pauseButton(),
                    nextButton()
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
              ],
            )),
      );
    }
  }

  String positionFormatter(int _durationMS) {
    int durationMS = _durationMS == null ? 0 : _durationMS;

    int second = durationMS ~/ 1000;

    int min = second ~/ 60;

    int secondReminder = second % 60;

    return min.toString() + ":" + secondReminder.toString();
  }

  Widget playButton() {
    return new IconButton(
      enableFeedback: true,
      splashColor: Colors.white,
      splashRadius: 65,
      highlightColor: Colors.white60,
      hoverColor: Colors.white,
      icon: new Icon(
        Icons.play_circle_outline,
        color: controlsColor,
      ),
      onPressed: () {

      App.getInstance().playBackController.resumeMusic();
      },
      iconSize: 65,
    );
  }

  Widget pauseButton() {
    return new IconButton(
      enableFeedback: true,
      splashColor: Colors.white,
      splashRadius: 65,
      highlightColor: Colors.white60,
      hoverColor: Colors.white,

      icon: new Icon(
        Icons.pause_circle_outline,
        color: controlsColor,
      ),
      onPressed: () {
      App.getInstance().playBackController.pauseMusic();
      },
      iconSize: 65,
    );
  }

  Widget previousButton() {
    return new IconButton(
      icon: new Icon(
        Icons.skip_previous,
        color: controlsColor,
      ),
      onPressed: () {
        App.getInstance().playBackController.prev();
      },
      iconSize: 50,
    );
  }

  Widget nextButton() {
    return new IconButton(
      icon: new Icon(
        Icons.skip_next,
        color: controlsColor,
      ),
      onPressed: () {
        App.getInstance().playBackController.next();
      },
      iconSize: 50,
    );
  }

  Widget emptyPlayBackState() {
    return Container(
      child: Text("no playback state yet"),
    );
  }

  Widget defaultCover() {
    return Container(
      child: Image.network(imgSrc),
    );
  }

  Widget artWork(Uint8List imageBytes) {
    return Container(
      child: Image.memory(imageBytes),
    );
  }
}
