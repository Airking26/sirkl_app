import 'dart:convert';

StoryCreationDto storyCreationDtoFromJson(String str) =>
    StoryCreationDto.fromJson(json.decode(str));

String storyCreationDtoToJson(StoryCreationDto data) =>
    json.encode(data.toJson());

class StoryCreationDto {
  StoryCreationDto({required this.url, required this.type});

  String url;
  int type;

  factory StoryCreationDto.fromJson(Map<String, dynamic> json) =>
      StoryCreationDto(url: json["url"], type: json["type"]);

  Map<String, dynamic> toJson() => {"url": url, "type": type};
}
