import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'marqueePainter.dart';

class Marquee extends StatefulWidget {
  final String text;
  final TextStyle _textStyle;
  Marquee(this.text,this._textStyle, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  //_MarqueeState createState() => _MarqueeState();
}

class MMarqueeState extends StatelessWidget {
  TextPainter _textPainter;
  double _textWidth;
  final String text;
  final TextStyle _textStyle;
  MMarqueeState(this.text,this._textStyle, {Key key}): super(key: key);
  AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    //super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
        child:
        SizedBox(
          height: _textStyle.fontSize+5,
          child:LayoutBuilder(
            builder: (context, boxConstraint) {
              return Container(
                  alignment: Alignment.center,
                  child: MarqueeAnimation(text, boxConstraint.maxWidth,_textStyle, key: UniqueKey()) );
            },
          ) ,
        )
        );
  }
}

class MarqueeAnimation extends StatefulWidget {
  final double containerWidth;
  final String text;
  final TextStyle _textStyle;
  MarqueeAnimation(this.text, this.containerWidth,this._textStyle, {Key key}) : super(key: key);

  @override
  _MarqueeAnimationState createState() => _MarqueeAnimationState();
}

class _MarqueeAnimationState extends State<MarqueeAnimation> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Tween _tween;

  String _text;
  double textWidth = 0;
  double dx = 0;
  double dxOffset = 0;
  double dxOffset2 = 0;
  TextPainter _textPainter;

  List<double> xOffsets = new List(1);

  var launchChild = false;
  int cycleCounter = 0;
  @override
  void initState() {
    super.initState();
    _text = widget.text;
    xOffsets[0] = 0;
    var inLineSpan = TextSpan(
        text: widget.text,
        style: widget._textStyle);
    _textPainter = new TextPainter(text: inLineSpan, textDirection: TextDirection.ltr);
    _textPainter.layout();

    textWidth = _textPainter.width;
    dxOffset2 =  widget.containerWidth;

    //print("my width " + _textPainter.width.toString());
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 15));


    var t = Tween<double>(begin: 0, end: _textPainter.width+widget.containerWidth);

    var anim = t.animate(_controller);

    anim..addListener(() {

      if (_controller.status == AnimationStatus.completed){
        cycleCounter++;
        _controller.forward(from: 1-_controller.value);
      }



      //dxOffset  = widget.containerWidth - _controller.value*(textWidth+widget.containerWidth);
      //dxOffset *= -1;
     // print("odd offset "  + dxOffset.toString());
     // print("odd value "  + _controller.value.toString());


      if (cycleCounter == 0){

        dxOffset = _controller.value*textWidth;

      }else{
        dxOffset  = widget.containerWidth - _controller.value*(textWidth+widget.containerWidth);
        dxOffset *= -1;
       // print("odd offset "  + dxOffset.toString());
     //   print("odd value "  + _controller.value.toString());
      }


      setState(() {
        dx = _controller.value;
        ///  dxOffset = _controller.value * textWidth;
        var screenSPace  = widget.containerWidth - (textWidth-dxOffset);

        xOffsets[0] = -dxOffset;

       // print("screen Space " + screenSPace.toString());
      });

    });

    Timer(Duration(milliseconds: 1000), (){
      if (textWidth > widget.containerWidth){
        _controller.forward();
      }
      // _controller.repeat(reverse: true);
    });

  }



  void update(String text){
    _text = text;
    _controller.stop();

    var inLineSpan = TextSpan(
        text: _text,
        style: widget._textStyle);
    _textPainter = new TextPainter(text: inLineSpan, textDirection: TextDirection.ltr);
    _textPainter.layout();
    textWidth = _textPainter.width;
    _tween = new Tween(begin: 0, end : textWidth+widget.containerWidth);

    _tween.animate(_controller).addListener(() {
      animationController();
    });

    Timer(Duration(milliseconds: 1000), (){

      if (textWidth > widget.containerWidth){
        _controller.forward();
      }
      // _controller.repeat(reverse: true);
    });

  }

  void animationController(){
    if (_controller.status == AnimationStatus.completed){
      cycleCounter++;
      _controller.forward(from: 1-_controller.value);
    }



    //dxOffset  = widget.containerWidth - _controller.value*(textWidth+widget.containerWidth);
    //dxOffset *= -1;
   // print("odd offset "  + dxOffset.toString());
   // print("odd value "  + _controller.value.toString());


    if (cycleCounter == 0){

      dxOffset = _controller.value*textWidth;

    }else{
      dxOffset  = widget.containerWidth - _controller.value*(textWidth+widget.containerWidth);
      dxOffset *= -1;
    //  print("odd offset "  + dxOffset.toString());
     /// print("odd value "  + _controller.value.toString());
    }


    setState(() {
      dx = _controller.value;
      ///  dxOffset = _controller.value * textWidth;
      var screenSPace  = widget.containerWidth - (textWidth-dxOffset);

      xOffsets[0] = -dxOffset;

   //   print("screen Space " + screenSPace.toString());
    });
  }



  void fowardanimation(double begin,double end , Duration d){

    var animationController = new AnimationController(vsync: this,duration:  d);

    Tween<double>(begin: begin,end: end).animate(animationController).addListener(() {

    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child:
      ClipRect(
        child:  CustomPaint(
          child: Container(width: double.infinity,height: 50,alignment: Alignment.center,),
          painter: MarqueePainter(_textPainter, xOffsets),
        ),
      )

      ,
    );
  }
}
