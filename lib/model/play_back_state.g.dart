// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_back_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayBackState _$PlayBackStateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const [
    'is_paused',
    'duration_ms',
    'playback_position',
    'track_name',
    'time_stamp'
  ]);
  return PlayBackState(
    json['is_paused'] as bool,
    json['duration_ms'] as int,
    json['playback_position'] as int,
    json['track_name'] as String,
    json['track_changed'] as bool ?? false,
    json['image_uri'] as String,
  )
    ..track = json['track'] == null
        ? null
        : Track.fromJson(json['track'] as Map<String, dynamic>)
    ..timeStamp = json['time_stamp'] as int
    ..rawState = json['rawState'] as Map<String, dynamic>
    ..isFresh = json['isFresh'] as bool
    ..isDragging = json['isDragging'] as bool ?? false;
}

Map<String, dynamic> _$PlayBackStateToJson(PlayBackState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('is_paused', instance.isPaused);
  writeNotNull('duration_ms', instance.duration);
  writeNotNull('playback_position', instance.playBackPosition);
  writeNotNull('track_name', instance.trackName);
  val['track'] = instance.track?.toJson();
  val['track_changed'] = instance.trackChanged;
  val['image_uri'] = instance.imageUri;
  writeNotNull('time_stamp', instance.timeStamp);
  val['rawState'] = instance.rawState;
  val['isFresh'] = instance.isFresh;
  val['isDragging'] = instance.isDragging;
  return val;
}
