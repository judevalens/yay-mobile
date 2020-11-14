import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/misc/marquee/marquee.dart';
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

  PlayBackController _playBackController = App.getInstance().playBackController;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controlsColor = Theme.of(context).primaryColor;
    // TODO: implement build
    return Selector<PlayBackState, bool>(selector: (_, _playBackState) {
      return _playBackState.isUnAvailable;
    }, builder: (context, isUnAvailable, child) {
      print("player is null");
      print(isUnAvailable);
      return _buildPlayer(isUnAvailable);
    });
  }

  Widget _buildPlayer(bool isUnAvailable) {
    if (isUnAvailable) {
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
                  child: Container(child: artWork()),
                ),
              ),

              trackNameArtistStream(),

              Column(
                children: [
                  progressBar(),
                  trackPosition(),
                ],
              ),
              Row(
                children: [previousButton(), resumePauseStream(), nextButton()],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
        ),
      );
    }
  }

  String positionFormatter(int _durationMS) {
    int durationMS = _durationMS == null ? 0 : _durationMS;

    int second = durationMS ~/ 1000;

    int min = second ~/ 60;

    int secondReminder = second % 60;

    // ADD a padding zero
    var secondString =
        (secondReminder / 10 < 1) ? ("0" + secondReminder.toString()) : secondReminder.toString();

    return min.toString() + ":" + secondString;
  }

  Widget progressBar() {
    return ChangeNotifierProvider.value(
      value: App.getInstance().playBackController.currentPlayBackState,
      child: ProgressBar(
        height: 10,
        seekCallBack: App.getInstance().playBackController.seek,
      ),
    );
  }

  Widget trackPosition() {
    return StreamBuilder<Tuple2<int, int>>(
      stream: _playBackController.trackPositionStreamController.stream,
      builder: (_, AsyncSnapshot<Tuple2<int, int>> snapshot) {
        var duration = 0;
        var pos = 0;

        if (snapshot.hasData) {
          print("duration " + snapshot.data.item2.toString());

          duration = snapshot.data.item2;
          pos = snapshot.data.item1;
        }

        return Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                positionFormatter(pos),
                style: new TextStyle(color: Colors.white),
              ),
              Text(
                positionFormatter(duration),
                style: new TextStyle(color: Colors.white),
              )
            ],
          ),
        );
      },
    );
  }

  Widget trackInfo(String track) {
    print("artist 1 ");
    print(_playBackController.currentPlayBackState.rawState["track"]["artist"]["name"]);
    return null;
  }

  Widget playButton() {
    return new IconButton(
      enableFeedback: true,
      splashColor: Colors.white,
      splashRadius: 65,
      highlightColor: Colors.white60,
      hoverColor: Colors.white,
      icon: new Icon(
        Icons.play_circle_filled,
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
        Icons.pause_circle_filled,
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
    return Image.network(imgSrc);
  }

  Widget artWork() {
    return StreamBuilder(
      stream: _playBackController.trackCoverStreamController.stream,
      builder: (_, AsyncSnapshot<Uint8List> snapShot) {
        Widget image;
        if (snapShot.hasData) {
          image = Image.memory(snapShot.data);
        }else {
          image = defaultCover();
        }
         return AnimatedSwitcher(duration: Duration(seconds: 2), child: Container(
           key: UniqueKey(),
        child: image,));
      },
    );
  }

  Widget resumePauseStream() {
    return StreamBuilder(
      stream: _playBackController.trackPlayStateStreamController.stream,
      builder: (_, AsyncSnapshot<bool> snapShot) {
        if (snapShot.hasData) {
          return snapShot.data ? playButton() : pauseButton();
        } else {
          return playButton();
        }
      },
    );
  }

  Widget trackNameArtistStream() {
    return StreamBuilder(
      stream: _playBackController.trackNameStreamController.stream,
      builder: (_, AsyncSnapshot<Tuple2<String, String>> snapShot) {


        var songTitle =  "No data";
        var artists = songTitle;


        if (snapShot.hasData){
             songTitle =  snapShot.data.item1 != null ? snapShot.data.item1 : "No data";
             artists =  snapShot.data.item2 != null ? snapShot.data.item2 : "No data";

             print("title has changed " +  snapShot.data.item1);


        }

          return Column(
            children: [
              Container(
                child: MMarqueeState(
                    songTitle,
                  TextStyle(color: Colors.white, fontSize: 25),
                    key : UniqueKey()
                ),
              ),

              Container(
                child: MMarqueeState(
                    artists,
                    TextStyle(color: Colors.white, fontSize: 20),
                    key : UniqueKey()
                ),
              )
            ],
          );
        }

    );
  }
}
