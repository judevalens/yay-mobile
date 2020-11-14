
import 'package:json_annotation/json_annotation.dart';
import 'package:yay/model/artist.dart';
part 'track.g.dart';

@JsonSerializable()
class Track{

  @JsonKey(name: "duration_ms")
  int duration;

  @JsonKey(name: "image_uri")
  String imageUri;

  @JsonKey(name: "uri")
  String trackUri;
  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "artist")
  Artist artist;

  @JsonKey(name: "artists")
  List<Artist> artists;

  Track(this.duration,this.imageUri,this.trackUri,this.name,this.artists);

  factory Track.fromJson(Map<String, dynamic> json) =>
      _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}