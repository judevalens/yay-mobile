import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  int totalPos, currentPos;
  Color progressBarColor;
  double percent = 0;
  ProgressBarPainter({this.totalPos, this.currentPos,this.progressBarColor,Listenable repaint}): super(repaint : repaint) ;

  ProgressBarPainter.fromPercent(this.percent,this.progressBarColor) : super(repaint: null);
  @override
  void paint(Canvas canvas, Size size) {
   // print("painter width is .. : " + size.width.toString());

    var startingPosition = size.center(Offset(0, 0));
    var startingPosition2 = size.topLeft(Offset(0, 0));

    var progressBarContainer = Rect.fromCenter(
        center: startingPosition, width: size.width, height: size.height);

    var progressBarContainerPaint  = Paint();
    progressBarContainerPaint.color = new Color.fromRGBO(214, 214, 214, 0.15);

    var progress = Rect.fromLTWH(startingPosition2.dx,  startingPosition2.dy, size.width*percent, size.height);
    canvas.drawRect(progressBarContainer, progressBarContainerPaint);
    var progressPaint  = Paint();
    progressPaint.color = progressBarColor;
    canvas.drawRect(progress,progressPaint );

    progressPaint.color = Colors.white;
    Offset circlePos = new Offset(size.width*percent, startingPosition2.dy+(size.height)/2);
    canvas.drawCircle(circlePos, (size.height*1.4)/2, progressPaint);
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;

  }
}
