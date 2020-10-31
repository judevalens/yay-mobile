
import 'package:json_annotation/json_annotation.dart';

part 'sync_play_back_state.g.dart';
@JsonSerializable(explicitToJson: true)
class SyncPlayBackState {
  @JsonKey(name: "track_id")
  String trackID;
  @JsonKey(name: "current_position")
  int currentPosition;

  SyncPlayBackState(this.trackID, this.currentPosition);

  factory SyncPlayBackState.fromJson(Map<String, dynamic> json) =>
      _$SyncPlayBackStateFromJson(json);

  Map<String, dynamic> toJson() => _$SyncPlayBackStateToJson(this);
}