// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) {
  return Track(
    json['duration_ms'] as int,
    json['image_uri'] as String,
    json['uri'] as String,
    json['name'] as String,
    (json['artists'] as List)
        ?.map((e) =>
            e == null ? null : Artist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..artist = json['artist'] == null
      ? null
      : Artist.fromJson(json['artist'] as Map<String, dynamic>);
}

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'duration_ms': instance.duration,
      'image_uri': instance.imageUri,
      'uri': instance.trackUri,
      'name': instance.name,
      'artist': instance.artist,
      'artists': instance.artists,
    };
