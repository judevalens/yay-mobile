
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/play_back_state.dart';
import 'package:yay/screens/player/progressBarPainter.dart';

import 'dart:math' as math;

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
  int totalPos =0;
  int currentPos = 0;
  double percent = 0;
  bool dragging = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Selector<PlayBackState, Tuple2<int,int>>(selector: (buildContext, playBackState) {
      print("spotify is null");
      print(playBackState);

      if(!dragging){
        totalPos = playBackState.track.duration;
        currentPos = playBackState.playBackPosition;
        percent = currentPos/totalPos;
      }

      return playBackState.playBackPosition != null ? Tuple2<int,int>(playBackState.playBackPosition,playBackState.track.duration) : 0 ;
    }, builder: (BuildContext context, Tuple2<int,int> value, Widget child) {

      return GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails){
          print("dragiing!!");
          print("current dx " + dragUpdateDetails.localPosition.dx.toString());
          setState(() {
            ///currentPos = dragUpdateDetails.globalPosition.dx.toInt()*totalPos;
            print("current pos dx " + currentPos.toString());
            currentPos = dragUpdateDetails.localPosition.dx.toInt()*totalPos;
            dragging = true;

            percent = dragUpdateDetails.localPosition.dx/(context.size.width);

            print("width is .. : " + context.size.width.toString());

            percent = math.min(percent, 1);
            percent = math.max(0,percent);

            print("percent is :" + percent.toString());

          });

        },
        onHorizontalDragEnd: (DragEndDetails forcePressDetails){
          setState(() {
            ///currentPos = dragUpdateDetails.globalPosition.dx.toInt()*totalPos;
            print("current pos dx " + currentPos.toString());
            dragging = false;

          });        },
          onHorizontalDragCancel: (){
            setState(() {
              ///currentPos = dragUpdateDetails.globalPosition.dx.toInt()*totalPos;
              print("current pos dx " + currentPos.toString());
              dragging = false;

            });
          },
        child: CustomPaint(
          painter: ProgressBarPainter.fromPercent(percent, Theme.of(context).primaryColor),
          child: FractionallySizedBox(
            widthFactor: 0.8,
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
