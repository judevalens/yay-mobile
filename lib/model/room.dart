import 'package:json_annotation/json_annotation.dart';
import 'package:yay/model/sync_play_back_state.dart';

part 'room.g.dart';
@JsonSerializable(explicitToJson: true)
class Room {
  @JsonKey(name: "room_id")
  String roomID;
  @JsonKey(name: "join_code")
  String joinCode;
  @JsonKey(name: "leader")
  String leader;
  @JsonKey(name: "members_ids")
  List<String> membersIDs;
  @JsonKey(name: "play_back_state")
  SyncPlayBackState playBackState;


  Room(this.roomID, this.joinCode, this.leader, this.membersIDs, this.playBackState);

  factory Room.fromJson(Map<String, dynamic> json) =>
      _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}