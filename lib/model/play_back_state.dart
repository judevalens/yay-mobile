import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
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
  @JsonKey(disallowNullValue: true, name: "track_changed")
  bool trackChanged;

  @JsonKey(ignore: true)
  bool isUnAvailable = false;
  PlayBackState(this.isPaused, this.duration, this.playBackPosition,
      this.trackName,this.trackChanged);

  PlayBackState.empty(){
    isUnAvailable = true;
  }

  factory PlayBackState.fromJson(Map<String, dynamic> json) =>
      _$PlayBackStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlayBackStateToJson(this);

  void updatePlayBackState(PlayBackState _playBackState) {
    isUnAvailable  = false;
    this.isPaused = _playBackState.isPaused;
    this.duration = _playBackState.duration;
    this.playBackPosition  = _playBackState.playBackPosition;
    this.track = _playBackState.track;
    notifyListeners();
  }

  void setPlayBackPosition(int playBackPosition){
    this.playBackPosition =  playBackPosition;
    notifyListeners();
  }

}