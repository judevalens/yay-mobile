import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/misc/marquee/marquee.dart';
import 'package:yay/model/play_back_state.dart';
import 'package:yay/screens%20v2/player/ProgressBar.dart';

import 'file:///C:/Users/judev/Documents/flutter%20projects/yay-mobile/lib/screens/home_screen/RoomPlayerPage.dart';

class PlayerPage extends StatefulWidget {
  final PageSwitcher pageSwitcher;

  PlayerPage({this.pageSwitcher});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayerPageState();
  }
}

class PlayerPageState extends State<PlayerPage> with AutomaticKeepAliveClientMixin {
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
    super.build(context);
    controlsColor = Theme.of(context).accentColor;
    // TODO: implement build
    return Selector<PlayBackState, bool>(selector: (_, _playBackState) {
      return _playBackState.isUnAvailable;
    }, builder: (context, isUnAvailable, child) {
      print("player is null");
      print(isUnAvailable);
      return _buildPlayer(isUnAvailable, widget.pageSwitcher);
    });
  }

  Widget _buildPlayer(bool isUnAvailable, PageSwitcher pageSwitcher) {
    if (isUnAvailable) {
      return emptyPlayBackState();
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 1,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                      child: Card(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: artWork(),
                    ),
                    color: Colors.white12,
                    elevation: 20,
                    shadowColor: Colors.black,
                  )),
                ),
              ),
              trackInfo(),
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
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_downward_sharp,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    pageSwitcher(1);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String formatTime(int _durationMS) {
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
        progressBarColor: Theme.of(context).colorScheme.secondary,
        progressBarBackground: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget trackPosition() {
    return StreamBuilder<Tuple2<int, int>>(
      stream: _playBackController.sTrackPositionStreamController.getStream(),
      builder: (_, AsyncSnapshot<Tuple2<int, int>> snapshot) {
        var duration = 0;
        var pos = 0;

        if (snapshot.hasData) {
          duration = snapshot.data.item2;
          pos = snapshot.data.item1;
        }

        return Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTime(pos),
                style: new TextStyle(color: Colors.white),
              ),
              Text(
                formatTime(duration),
                style: new TextStyle(color: Colors.white),
              )
            ],
          ),
        );
      },
    );
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
        } else {
          image = defaultCover();
        }
        return AnimatedSwitcher(
            duration: Duration(milliseconds: 1000),
            child: Container(
              key: UniqueKey(),
              child: image,
            ));
      },
    );
  }

  Widget resumePauseStream() {
    return StreamBuilder(
      stream: _playBackController.trackPlayStateStreamController.getStream(),
      builder: (_, AsyncSnapshot<bool> snapShot) {
        if (snapShot.hasData) {
          return snapShot.data ? playButton() : pauseButton();
        } else {
          return playButton();
        }
      },
    );
  }

  Widget trackInfo() {
    return StreamBuilder(
        stream: _playBackController.trackNameStreamController.stream,
        builder: (_, AsyncSnapshot<Tuple2<String, String>> snapShot) {
          var songTitle = "No data";
          var artists = songTitle;

          if (snapShot.hasData) {
            songTitle = snapShot.data.item1 != null ? snapShot.data.item1 : "No data";
            artists = snapShot.data.item2 != null ? snapShot.data.item2 : "No data";

            print("title has changed " + snapShot.data.item1);
          }

          return Column(
            children: [
              Container(
                child: MMarqueeState(songTitle, TextStyle(color: Colors.white, fontSize: 25),
                    key: UniqueKey()),
              ),
              Container(
                child: MMarqueeState(artists, TextStyle(color: Colors.white, fontSize: 20),
                    key: UniqueKey()),
              )
            ],
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
