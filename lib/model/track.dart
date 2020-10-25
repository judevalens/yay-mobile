
import 'package:json_annotation/json_annotation.dart';
part 'track.g.dart';

@JsonSerializable()
class Track{

  @JsonKey(name: "duration_ms")
  int duration;

  @JsonKey(name: "image_uri")
  String imageUri;

  @JsonKey(name: "uri")
  String trackUri;

  Track(this.duration,this.imageUri,this.trackUri);

  factory Track.fromJson(Map<String, dynamic> json) =>
      _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}