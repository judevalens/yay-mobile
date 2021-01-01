import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/play_back_state.dart';
import 'package:yay/screens/player/progressBarPainter.dart';

import 'dart:math' as math;

typedef SeekCallBack = void Function(double pos);

class ProgressBar extends StatefulWidget {
  final int height, width;
  final SeekCallBack seekCallBack;
  final Color progressBarColor;
  final Color progressBarBackground;
  ProgressBar({this.height, this.width, this.seekCallBack, this.progressBarColor, this.progressBarBackground});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProgressBarState(height: height, seekCallBack: seekCallBack);
  }
}

class ProgressBarState extends State<ProgressBar> {
  final SeekCallBack seekCallBack;

  int height;

  ProgressBarState({this.height, this.seekCallBack});

  int totalPos = 0;
  int currentPos = 0;
  double percent = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Selector<PlayBackState, Tuple2<int, int>>(selector: (buildContext, playBackState) {
    //  print("spotify is null");
     // print(playBackState);


        totalPos = playBackState.track.duration;
        currentPos = playBackState.playBackPosition;
        percent = currentPos / totalPos;

      return playBackState.playBackPosition != null
          ? Tuple2<int, int>(playBackState.playBackPosition, playBackState.track.duration)
          : 0;
    }, builder: (BuildContext context, Tuple2<int, int> value, Widget child) {
      return GestureDetector(
        onHorizontalDragStart: (DragStartDetails dragStartDetails){
          percent = dragStartDetails.localPosition.dx / (context.size.width);
          percent = math.min(percent, 1);
          percent = math.max(0, percent);
          double posToSeek = percent * totalPos;
            print("drag start !!!!!!!!");
          App.getInstance().playBackController.dragStart(posToSeek);
        },
        onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) {
          print("dragiing!!");
          print("current dx " + dragUpdateDetails.localPosition.dx.toString());

          percent = dragUpdateDetails.localPosition.dx / (context.size.width);
          percent = math.min(percent, 1);
          percent = math.max(0, percent);
          double posToSeek = percent * totalPos;
          App.getInstance().playBackController.drag(posToSeek);


        },
        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
          double posToSeek = percent * totalPos;
         // seekCallBack(posToSeek);
          App.getInstance().playBackController.dragEnd(posToSeek);

        },
        child: CustomPaint(
          painter: ProgressBarPainter.fromPercent(percent, widget.progressBarColor,widget.progressBarBackground),
          child: FractionallySizedBox(
            widthFactor: 1,
            child: SizedBox(
              width: double.infinity,
              height: height.toDouble(),
            ),
          ),
        ),
      );
    });
  }
}
