import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/PlayBackController.dart';
import 'package:yay/misc/marquee/marquee.dart';

import 'file:///C:/Users/judev/Documents/flutter%20projects/yay-mobile/lib/screens/home_screen/RoomPlayerPage.dart';

import 'ProgressBar.dart';

class Player extends StatefulWidget {
  final PageSwitcher pageSwitcher;

  Player({this.pageSwitcher});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayerState();
  }
}

class PlayerState extends State<Player> with AutomaticKeepAliveClientMixin {
  int playStatus = 0;
  String imgSrc =
      "https://static.standard.co.uk/s3fs-public/thumbnails/image/2019/09/20/15/animalistic-imagery-runs-throughout-the-exhibition.jpg";
  Color controlsColor;

  PlayBackController _playBackController = App.getInstance().playBackController;

  int tweetFlowContainerHeight = 350;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    controlsColor = Theme.of(context).colorScheme.secondary;
    // TODO: implement build

    return body(context);
  }

  Widget body(BuildContext context){
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: LayoutBuilder(builder: (context,constraint){
        print("constraint " + constraint.maxHeight.toString());

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraint.maxHeight,
            ),
            child:FractionallySizedBox(
              widthFactor: 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildPlayer(constraint.maxHeight-(tweetFlowContainerHeight*0.2),context),
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    height: 350,
                    alignment: Alignment.center,
                    child: Column(
                      children: [Text("Tweet Flow"),Expanded(child: Container(child: Text("No tweet found"),))],
                    ),
                  )
                ],
              ),
            ),
          ),
        );

      }),
    );
  }

  Widget _buildPlayer(double height,BuildContext context) {
    return Container(
      height: height,
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+50, bottom: 50),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Material(
              elevation: 25,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: artWork(),
              ),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: trackInfo(context)),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              progressBar(context),
              trackPosition(context),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),

          child: Row(
            children: [previousButton(), resumePauseStream(), nextButton()],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        )
      ],),
    );
  }


  // TODO DOESNT BELONG HERE
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

  Widget progressBar(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: App.getInstance().playBackController.currentPlayBackState,
      child: ProgressBar(
        height: 5,
        seekCallBack: App.getInstance().playBackController.seek,
        progressBarColor: Theme.of(context).colorScheme.secondary,
        progressBarBackground: Colors.black12,
      ),
    );
  }

  Widget trackPosition(BuildContext context) {
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
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
              ),
              Text(
                formatTime(duration),
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
              )
            ],
          ),
        );
      },
    );
  }

  Widget playButton() {
    return Material(
      type: MaterialType.transparency,
      color: controlsColor,
      //  shape: CircleBorder(),
      child: new RawMaterialButton(
        padding: EdgeInsets.all(5.0),
        shape: CircleBorder(),
        child: new Icon(
          Icons.play_circle_filled,
          size: 70,
          color: controlsColor,
        ),
        onPressed: () async {
          App.getInstance().playBackController.resumeMusic();
        },
      ),
    );
  }

  Widget pauseButton() {
    return Material(
      type: MaterialType.transparency,
      color: controlsColor,
      //  shape: CircleBorder(),
      child: new RawMaterialButton(
        padding: EdgeInsets.all(5.0),
        shape: CircleBorder(),
        child: new Icon(
          Icons.pause_circle_filled,
          size: 70,
          color: controlsColor,
        ),
        onPressed: () {
          App.getInstance().playBackController.pauseMusic();
        },
      ),
    );
  }

  Widget previousButton() {
    return Material(
      type: MaterialType.transparency,
      child: new RawMaterialButton(
        shape: CircleBorder(),
        child: new Icon(
          Icons.skip_previous,
          size: 50,
          color: controlsColor,
        ),
        onPressed: () {
          App.getInstance().playBackController.prev();
        },
      ),
    );
  }

  Widget nextButton() {
    return Material(
      type: MaterialType.transparency,
      child: new RawMaterialButton(
        shape: CircleBorder(),
        child: new Icon(
          Icons.skip_next,
          size: 50,
          color: controlsColor,
        ),
        onPressed: () {
          App.getInstance().playBackController.next();
        },
      ),
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
      stream: _playBackController.sTrackCoverStreamController.getStream(),
      builder: (_, AsyncSnapshot<Uint8List> snapShot) {
        Widget image;
        if (snapShot.hasData) {
          image = Image.memory(snapShot.data);
        } else {
          image = defaultCover();
        }
        return AnimatedSwitcher(
            key: ValueKey("my animated switcher"),
            duration: Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey(image),
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

  Widget trackInfo(BuildContext context) {
    return StreamBuilder(
        stream: _playBackController.sTrackNameStreamController.getStream(),
        builder: (_, AsyncSnapshot<Tuple2<String, String>> snapShot) {
          var songTitle = "No data";
          var artists = songTitle;

          if (snapShot.hasData) {
            songTitle = snapShot.data.item1 != null ? snapShot.data.item1 : "No data";
            artists = snapShot.data.item2 != null ? snapShot.data.item2 : "No data";

            print("title has changed " + snapShot.data.item1);
          }

          return Container(

            child: Column(
              children: [
                Container(
                  child: MMarqueeState(songTitle,
                      TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 30, fontWeight: FontWeight.bold),
                      key: UniqueKey()),
                ),
                Container(
                  child: MMarqueeState(artists,
                      TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 20),
                      key: UniqueKey()),
                )
              ],
            ),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
