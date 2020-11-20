

//SSCMS : SingleStreamControllerWithMultipleSubscription
import 'dart:async';
import 'package:async/async.dart';
class SingleSCMultipleSubscriptions<T>{
  // ignore: close_sinks
  StreamController<T> controller;
  StreamSplitter<T> _streamSplitter;
  SingleSCMultipleSubscriptions(){
    controller = new StreamController();
    _streamSplitter = new StreamSplitter(controller.stream);

  }


  Stream<T> getStream(){
    return _streamSplitter.split();
  }



}