// To parse this JSON data, do
//
//     final storyCreationDto = storyCreationDtoFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

StoryCreationDto storyCreationDtoFromJson(String str) => StoryCreationDto.fromJson(json.decode(str));

String storyCreationDtoToJson(StoryCreationDto data) => json.encode(data.toJson());

class StoryCreationDto {
  StoryCreationDto({
    required this.url,
  });

  String url;

  factory StoryCreationDto.fromJson(Map<String, dynamic> json) => StoryCreationDto(
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}
