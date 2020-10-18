import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yay/model/play_back_state.dart';

class PlayBackController {
  static const String PLAY_BACK_CHANNEL_NAME = "playBackStateTunnel";
  MethodChannel playBackChannel = new MethodChannel(PLAY_BACK_CHANNEL_NAME);
  Isolate playerUpdateIsolate;
  // main thread receiver port
  ReceivePort positionUpdaterRp;
  SendPort positionUpdaterSendPort;
  PlayBackState currentPlayBackState;
  PlayBackController(){
    currentPlayBackState = PlayBackState.empty();
   /// init();
  }

  init(){
    positionUpdaterRp = new ReceivePort();
    playBackChannel.setMethodCallHandler((call) {
      print("player state changed !! Flutter from controller");
      switch (call.method) {
        case "updatePlayerState":
          print("calling updatePlayerState");
          print("playBackState");
          print(call.arguments);
          var playBackJson =  jsonDecode(call.arguments);
          PlayBackState playBackState = PlayBackState.fromJson(playBackJson);
          print("playBackState 2");
          print(playBackState);
          updatePlayerState(playBackState);
          break;
      }

      return null;
    });


    positionUpdaterRp.listen((message) {
      print("new msg");
      print(message.runtimeType);
      if (message is SendPort) {
        print("set port");
        positionUpdaterSendPort = message;
      }
      else if(message is int){
          print("received new position from isolate");
          currentPlayBackState.setPlayBackPosition(message);
      }
    });


    Isolate.spawn(updatePosition, positionUpdaterRp.sendPort);
  }

  void updatePlayerState(PlayBackState playBackState) {
    print("received playBack");
    currentPlayBackState.updatePlayBackState(playBackState);
    if (positionUpdaterSendPort != null) {
      print("sent playBack");
      positionUpdaterSendPort.send(playBackState);
    }
  }

  static void updatePosition(SendPort positionUpdaterSendPort) {
    print("new state!!!!!");

    int currentTrackPosition = 0;
    // Receive PlayBack state object from the spotify sdk
    ReceivePort positionUpdaterRp = ReceivePort();

    // Send a new send port the spawner. This will allows communication between this isolate and the main thread*
    positionUpdaterSendPort.send(positionUpdaterRp.sendPort);
    // Used to update the position of  track being played unless we receive a new playBack state
    Timer timer;
    positionUpdaterRp.listen((_playBackState) {
      PlayBackState playBackState = _playBackState;
      currentTrackPosition = playBackState.playBackPosition;
      if (playBackState is PlayBackState) {
        print("new state!!!!! 1");
        if (playBackState.isPaused) {
          if (timer != null) {
            timer.cancel();
            timer = null;
          }
        } else {
          if (timer == null) {
            timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
              currentTrackPosition += 1;
              positionUpdaterSendPort.send(currentTrackPosition);
            });
          }
        }
      }
    });
  }}