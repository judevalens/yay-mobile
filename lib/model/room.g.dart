// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) {
  return Room(
    json['room_id'] as String,
    json['join_code'] as String,
    json['leader'] as String,
    (json['members_ids'] as List)?.map((e) => e as String)?.toList(),
    json['play_back_state'] == null
        ? null
        : SyncPlayBackState.fromJson(
            json['play_back_state'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'room_id': instance.roomID,
      'join_code': instance.joinCode,
      'leader': instance.leader,
      'members_ids': instance.membersIDs,
      'play_back_state': instance.playBackState?.toJson(),
    };
