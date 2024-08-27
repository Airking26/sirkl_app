import 'dart:convert';

import 'package:sirkl/common/model/sign_in_success_dto.dart';

List<List<StoryDto>> storyDtoFromJson(String str) =>
    List<List<StoryDto>>.from(json
        .decode(str)
        .map((x) => List<StoryDto>.from(x.map((x) => StoryDto.fromJson(x)))));
List<StoryDto> myStoryDtoFromJson(String str) =>
    List<StoryDto>.from(json.decode(str).map((x) => StoryDto.fromJson(x)));

String storyDtoToJson(List<List<StoryDto>> data) =>
    json.encode(List<dynamic>.from(
        data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))));
String myStoryDtoToJson(List<StoryDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StoryDto {
  StoryDto(
      {required this.createdBy,
      required this.readers,
      required this.url,
      required this.createdAt,
      required this.id,
      required this.type});

  UserDTO createdBy;
  List<String> readers;
  String url;
  DateTime createdAt;
  String id;
  int type;

  factory StoryDto.fromJson(Map<String, dynamic> json) => StoryDto(
      createdBy: UserDTO.fromJson(json["createdBy"]),
      readers: List<String>.from(json["readers"].map((x) => x)),
      url: json["url"],
      id: json['id'],
      createdAt: DateTime.parse(json["createdAt"]),
      type: json["type"]);

  Map<String, dynamic> toJson() => {
        "createdBy": createdBy.toJson(),
        "readers": List<dynamic>.from(readers.map((x) => x)),
        "url": url,
        "createdAt": createdAt.toIso8601String(),
        "id": id,
        'type': type
      };
}
