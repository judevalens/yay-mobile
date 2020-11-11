import 'package:flutter/cupertino.dart';

class MarqueePainter extends CustomPainter{
  TextPainter _textPainter;
  String text;
  TextStyle _textStyle;
  double xPos = 0;
  double yPost = 0;

  List<double> xOffsets;
  MarqueePainter(this._textPainter,this.xOffsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    var offset = Offset(xPos, yPost);
    var offset2 = Offset(-xPos-500, yPost);
    _textPainter.layout();
  //  _textPainter.paint(canvas, offset);



    xOffsets.forEach((element) {
      var offset = Offset(element, yPost);

      _textPainter.paint(canvas, offset);

    });


    print("text width " + _textPainter.width.toDouble().toString());
    print("canvas width " +size.width.toDouble().toString());

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}