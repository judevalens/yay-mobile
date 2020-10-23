import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yay/model/play_back_state.dart';

class PlayBackController {
  static const String PLAY_BACK_CHANNEL_NAME = "playBackStateTunnel";
  static const String MC_UPDATE = "updatePlayerState";
  static const String MC_SUBSCRIBE_TO_PLAYBACK_STATE = "SubscribeToPlayBackState";
  static const String MC_PLAY = "play";
  static const String MC_PAUSE = "pause";
  static const String MC_SEEK = "seek";
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

  /// Set up an isolate to update the playBack position. Calls method to subscribe to the spotify playback
  init(){
    positionUpdaterRp = new ReceivePort();
    playBackChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case MC_UPDATE:
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
        // once the isolate to update the progress is set up, we subscribe to the player playback  state
        playBackChannel.invokeMethod(MC_SUBSCRIBE_TO_PLAYBACK_STATE);
        
      }
      else if(message is int){
          print("received new position from isolate");
          currentPlayBackState.setPlayBackPosition(message);
      }
    });


    Isolate.spawn(updatePosition, positionUpdaterRp.sendPort);


    void playMusic() {
      playBackChannel.invokeMethod("play");
    }

    void pauseMusic() {
      playBackChannel.invokeMethod("pause");
    }

    void seek(double position) {
      playBackChannel.invokeMethod("seek", [position]);
    }
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

