// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_play_back_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncPlayBackState _$SyncPlayBackStateFromJson(Map<String, dynamic> json) {
  return SyncPlayBackState(
    json['track_id'] as String,
    json['current_position'] as int,
  );
}

Map<String, dynamic> _$SyncPlayBackStateToJson(SyncPlayBackState instance) =>
    <String, dynamic>{
      'track_id': instance.trackID,
      'current_position': instance.currentPosition,
    };
