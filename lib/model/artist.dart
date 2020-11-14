
import 'package:json_annotation/json_annotation.dart';
part 'artist.g.dart';

@JsonSerializable()
class Artist{

  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "uri")
  String artistUri;


  Artist(this.name,this.artistUri);

  factory Artist.fromJson(Map<String, dynamic> json) =>
      _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}