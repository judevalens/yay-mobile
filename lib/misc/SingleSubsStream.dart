

//SSCMS : SingleStreamControllerWithMultipleSubscription
import 'dart:async';
import 'package:async/async.dart';
class SingleSCMultipleSubscriptions<T>{
  // ignore: close_sinks
  StreamController<T> controller;
  StreamSplitter<T> _streamSplitter;
  bool brandNew = false;
  SingleSCMultipleSubscriptions(){
    controller = new StreamController();
    _streamSplitter = new StreamSplitter(controller.stream);

  }


  Stream<T> getStream(){
    return _streamSplitter.split();
  }



}