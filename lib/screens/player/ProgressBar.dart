import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/play_back_state.dart';
import 'package:yay/screens/player/progressBarPainter.dart';

class ProgressBar extends StatefulWidget{

  final int height,width;
  ProgressBar({this.height, this.width});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProgressBarState(height: height);
  }

}

class ProgressBarState extends State<ProgressBar> {

  int height;
  ProgressBarState({this.height});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Selector<PlayBackState, Tuple2<int,int>>(selector: (buildContext, playBackState) {
      print("spotify is null");
      print(playBackState);
      return playBackState.playBackPosition != null ? Tuple2<int,int>(playBackState.playBackPosition,playBackState.track.duration) : 0 ;
    }, builder: (BuildContext context, Tuple2<int,int> value, Widget child) {
      return CustomPaint(
        painter: ProgressBarPainter( currentPos: value.item1,totalPos: value.item2),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: SizedBox(
            width: double.infinity,
            height: height.toDouble(),
          ),
        ),
      );
    });
  }

}
