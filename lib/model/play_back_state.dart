import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/track.dart';

part 'play_back_state.g.dart';
@JsonSerializable(explicitToJson: true)
class PlayBackState extends ChangeNotifier{

  @JsonKey(disallowNullValue: true, name: "is_paused")
  bool isPaused;
  @JsonKey(disallowNullValue: true, name: "duration_ms")
  int duration;
  @JsonKey(disallowNullValue: true, name: "playback_position")
  int playBackPosition;
  @JsonKey(disallowNullValue: true, name: "track_name")
  String trackName;
  @JsonKey(ignore: true,disallowNullValue: true, name: "artists")
  List<String> artists;
  @JsonKey(name: "track")
  Track track;
  @JsonKey(name: "track_changed", defaultValue: false)
  bool trackChanged;

  @JsonKey(name: "image_uri")
  String imageUri;

  @JsonKey(ignore: true)
  Uint8List coverImage;


  @JsonKey(disallowNullValue: true, name: "time_stamp")
  int timeStamp;

  Map<String,dynamic>rawState;


  bool isFresh;

  @JsonKey(defaultValue: false)
  bool isDragging = false;

  @JsonKey(ignore: true)
  bool isUnAvailable = false;
  PlayBackState(this.isPaused, this.duration, this.playBackPosition,
      this.trackName,this.trackChanged,this.imageUri);

  PlayBackState.empty(){
    isUnAvailable = true;
    isDragging = false;
  }

  PlayBackState.clone(PlayBackState _playBackState){
    isUnAvailable  = false;
    this.isPaused = _playBackState.isPaused;
    this.duration = _playBackState.duration;
    this.playBackPosition  = _playBackState.playBackPosition;
    this.track = _playBackState.track;
    this.isFresh  = true;
    this.isDragging = _playBackState.isDragging;
  }

  factory PlayBackState.fromJson(Map<String, dynamic> json) =>
      _$PlayBackStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlayBackStateToJson(this);

  void updatePlayBackState(PlayBackState _playBackState) {
    isUnAvailable  = false;
    this.isPaused = _playBackState.isPaused;
    this.duration = _playBackState.duration;


    this.playBackPosition  = _playBackState.playBackPosition;

    if(this.track != null){
      this.trackChanged = this.track.trackUri != _playBackState.track.trackUri;
    }else{
      this.trackChanged  = true;
    }

    this.track = _playBackState.track;
    this.imageUri = _playBackState.imageUri;

    App.getInstance().playBackController.trackPositionStreamController.add(new Tuple2<int,int>(this.playBackPosition,this.track.duration));
    App.getInstance().playBackController.trackPlayStateStreamController.add(this.isPaused);


    if(trackChanged){
      App.getInstance().playBackController.getArtWork(imageUri);

      String artistList =  "";
      int counter  = 0;
      for (var value in this.track.artists) {
        artistList += value.name;

        counter++;

        if (counter < this.track.artists.length){
          artistList += ", ";
        }

      }

      App.getInstance().playBackController.trackNameStreamController.add(Tuple2<String,String>(this.track.name,artistList));
      ///queryArtWOrk();
    }

    print("trackChanged  " + trackChanged.toString() +" trackURI  " + this.track.trackUri);

    this.isFresh  = true;
    notifyListeners();
  }

  void setCoverImage(Uint8List imageByte){
    this.coverImage = imageByte;
    App.getInstance().playBackController.trackCoverStreamController.add(imageByte);
  }

  void queryArtWOrk(){
    String queryEndPoint = "https://api.spotify.com/v1/tracks/" + this.track.trackUri;
  App.getInstance().nt.queryWebApi(queryEndPoint).then((trackObject) => () {
    print("queried cover");
    print(trackObject);
  });
  }

  void setPlayBackPosition(int playBackPosition){
    this.playBackPosition =  playBackPosition;
    App.getInstance().playBackController.trackPositionStreamController.add(new Tuple2<int,int>(this.playBackPosition,this.track.duration));

    notifyListeners();
  }

  void setPlayBackPositionFromDragging(){

  }

  bool isEqual(PlayBackState a,PlayBackState b){
    if (a.track.trackUri != b.track.trackUri || a.isPaused != b.isPaused){
      return false;
    }

    if (a.playBackPosition != b.playBackPosition){
      return false;
    }



    return true;
  }

}