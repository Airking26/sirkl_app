// To parse this JSON data, do
//
//     final updateMeDto = updateMeDtoFromJson(jsonString);

import 'dart:convert';

UpdateMeDto updateMeDtoFromJson(String str) => UpdateMeDto.fromJson(json.decode(str));

String updateMeDtoToJson(UpdateMeDto data) => json.encode(data.toJson());

class UpdateMeDto {
  UpdateMeDto({
    this.userName,
    this.picture,
    this.description,
    this.nicknames
  });

  String? userName;
  String? picture;
  String? description;
  Map<String, String>? nicknames;

  factory UpdateMeDto.fromJson(Map<String, dynamic> json) => UpdateMeDto(
    userName: json["userName"],
    picture: json["picture"],
    description: json["description"],
    nicknames: json['nicknames']
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "picture": picture,
    "description": description,
    "nicknames": nicknames
  };
}
