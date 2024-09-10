import 'dart:convert';

StoryModificationDto storyModificationDtoFromJson(String str) =>
    StoryModificationDto.fromJson(json.decode(str));

String storyModificationDtoToJson(StoryModificationDto data) =>
    json.encode(data.toJson());

class StoryModificationDto {
  StoryModificationDto({
    required this.id,
    required this.readers,
  });

  String id;
  List<String> readers;

  factory StoryModificationDto.fromJson(Map<String, dynamic> json) =>
      StoryModificationDto(
        id: json["id"],
        readers: List<String>.from(json["readers"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "readers": List<dynamic>.from(readers.map((x) => x)),
      };
}
