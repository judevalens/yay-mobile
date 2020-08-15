import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  int totalPos, currentPos;

  ProgressBarPainter({this.totalPos, this.currentPos,Listenable repaint}): super(repaint : repaint) ;
  @override
  void paint(Canvas canvas, Size size) {
    var startingPosition = size.center(Offset(0, 0));
    var startingPosition2 = size.topLeft(Offset(0, 0));

    var progressBarContainer = Rect.fromCenter(
        center: startingPosition, width: size.width, height: size.height);
    var percent  = currentPos/totalPos;
    var progress = Rect.fromLTWH(startingPosition2.dx,  startingPosition2.dy, size.width*percent, size.height);
    canvas.drawRect(progressBarContainer, Paint());
    var progressPaint  = Paint();
    progressPaint.color = Colors.red;
    canvas.drawRect(progress,progressPaint );
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;

  }
}
