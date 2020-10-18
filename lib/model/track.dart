
import 'package:json_annotation/json_annotation.dart';
part 'track.g.dart';

@JsonSerializable()
class Track{

  @JsonKey(name: "duration_ms")
  int duration;

  Track(this.duration);

  factory Track.fromJson(Map<String, dynamic> json) =>
      _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}