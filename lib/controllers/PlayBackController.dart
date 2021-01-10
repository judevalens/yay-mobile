import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/misc/SingleSubsStream.dart';
import 'package:yay/model/play_back_state.dart';

enum playerMode { NORMAL, LISTENING, STREAMING }

class PlayBackController {
  static const String PLAY_BACK_CHANNEL_NAME = "playBackStateTunnel";
  static const String MC_UPDATE = "updatePlayerState";
  static const String MC_SUBSCRIBE_TO_PLAYBACK_STATE = "SubscribeToPlayBackState";
  static const String MC_START = "start";
  static const String MC_RESUME = "resume";
  static const String MC_PAUSE = "pause";
  static const String MC_SEEK = "seek";
  static const String MC_NEXT = "next";
  static const String MC_PREV = "prev";
  static const String MC_GET_ART_WORK = "artwork";
  static const String MC_GET_PLAY_BACK_STATE = "getPlayBackState";
  MethodChannel playBackChannel = new MethodChannel(PLAY_BACK_CHANNEL_NAME);
  Isolate playerUpdateIsolate;

  // main thread receiver port
  ReceivePort positionUpdaterRp;
  SendPort positionUpdaterSendPort;
  PlayBackState currentPlayBackState;

  bool isPositionUpdaterActive = false;
  bool isDragging = false;

  bool isInitialized;
  Isolate positionUpdaterIsolate;

  playerMode currentMode = playerMode.NORMAL;

  // ignore: close_sinks
  StreamController<Tuple2<int, int>> trackPositionStreamController;
  StreamController<Uint8List> trackCoverStreamController;
  StreamController<Tuple2<String,String>> trackNameStreamController;
  SingleSCMultipleSubscriptions<Tuple2<int, int>> sTrackPositionStreamController;
  SingleSCMultipleSubscriptions<Tuple2<String, String>> sTrackNameStreamController;
  SingleSCMultipleSubscriptions<Uint8List> sTrackCoverStreamController;
  SingleSCMultipleSubscriptions<bool> trackPlayStateStreamController;
  SingleSCMultipleSubscriptions<bool> newTrackStreamController;

  PlayBackController() {
    isInitialized = false;
    currentPlayBackState = PlayBackState.empty();


    watchAuthorization();
  }

  /// Set up an isolate to update the playBack position. Calls method to subscribe to the spotify playback
  ///

  init() async {

    trackPositionStreamController = new StreamController();
    trackCoverStreamController = new StreamController();
    trackPlayStateStreamController = new SingleSCMultipleSubscriptions();
    trackNameStreamController = new StreamController();

    sTrackPositionStreamController = new SingleSCMultipleSubscriptions();
    sTrackNameStreamController = new SingleSCMultipleSubscriptions();
    sTrackCoverStreamController = new SingleSCMultipleSubscriptions();
    newTrackStreamController = new SingleSCMultipleSubscriptions();

    positionUpdaterRp = new ReceivePort();
    playBackChannel.setMethodCallHandler(
      (call) {
        switch (call.method) {
          case MC_UPDATE:
            print("calling updatePlayerState");
            print("playBackState");
            print(call.arguments);
            var playBackJson = jsonDecode(call.arguments);
            PlayBackState playBackState = PlayBackState.fromJson(playBackJson);
            print("playBackState 2");
            print(playBackState);
            updatePlayerState(playBackState);
            currentPlayBackState.rawState = playBackJson;

            if (currentMode == playerMode.STREAMING) {
              //App.getInstance().roomController.streamPlayBackState(playBackJson);
            }

            break;
        }

        return null;
      },
    );

    positionUpdaterRp.listen((message) {
      //print("new msg");
      if (message is SendPort) {
        print("set port");
        positionUpdaterSendPort = message;
        // once the isolate to update the progress is set up, we subscribe to the player playback  state
        playBackChannel.invokeMethod(MC_SUBSCRIBE_TO_PLAYBACK_STATE);
      } else if (message is int) {
      //  print("received new position from isolate");
        currentPlayBackState.setPlayBackPosition(message);
        currentPlayBackState.isFresh = false;
      } else if (message is bool) {
        isPositionUpdaterActive = message;
      }
    });

    positionUpdaterIsolate = await Isolate.spawn(updatePosition, positionUpdaterRp.sendPort);
    isInitialized = true;
  }

  void watchAuthorization() {
    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        if (!isInitialized) {
          init();
        }
      } else {
        if (isInitialized) {
          shutdown();
        }
      }
    });
  }

  void shutdown() {
    // positionUpdaterIsolate.kill();
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
        if (playBackState.isPaused || playBackState.isDragging) {
          if (timer != null) {
            timer.cancel();
            timer = null;
          }
          positionUpdaterSendPort.send(false);
        } else {
          if (timer == null) {
            positionUpdaterSendPort.send(true);
            timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
              currentTrackPosition += 1;
              positionUpdaterSendPort.send(currentTrackPosition);
              positionUpdaterSendPort.send(true);
            });
          }
        }
      }
    });
  }


  void start(String musicID){
    playBackChannel.invokeMethod(MC_START,musicID);

  }




  void resumeMusic() {
    playBackChannel.invokeMethod(MC_RESUME);
  }

  void pauseMusic() {
    playBackChannel.invokeMethod(MC_PAUSE);
  }

  void seek(double position) {
    playBackChannel.invokeMethod(MC_SEEK, position);
  }

  void next() {
    playBackChannel.invokeMethod(MC_NEXT);
  }

  void prev() {
    playBackChannel.invokeMethod(MC_PREV);
  }

  void getArtWork(String imageUri) {
    print("sending call for artwork : " + imageUri);
    playBackChannel.invokeMethod(MC_GET_ART_WORK, imageUri).then((value) {
      print("image cover");
      var imageByte = value as Uint8List;
      print(imageByte.length);

      currentPlayBackState.setCoverImage(imageByte);
      print(value);
    });
  }

  void dragStart(double position) {
    isDragging = true;
    currentPlayBackState.isDragging = isDragging;

    PlayBackState _currentPlayBackState = new PlayBackState.clone(currentPlayBackState);

    positionUpdaterSendPort.send(_currentPlayBackState);
    //if(!isPositionUpdaterActive) {
    _currentPlayBackState.setPlayBackPosition(position.toInt());
    //}
    print("drag start!!!");
  }

  drag(double position) {
    currentPlayBackState.setPlayBackPosition(position.toInt());
  }

  dragEnd(double position) {
    isDragging = false;
    currentPlayBackState.isDragging = isDragging;
    PlayBackState _currentPlayBackState = new PlayBackState.clone(currentPlayBackState);
    positionUpdaterSendPort.send(_currentPlayBackState);
    seek(position);
  }

  setCurrentMode(playerMode mode) async {
    currentMode = mode;
    pauseMusic();

    /// give time to stop current track
    await Future.delayed(new Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> getPlayBackState() async {
    print("requesting state");
    var playerStateJSonString = await playBackChannel.invokeMethod(MC_GET_PLAY_BACK_STATE);
    return jsonDecode(playerStateJSonString);
  }

  void sync(Map<String, String> playbackState) {}

  void compareState() {}
}
