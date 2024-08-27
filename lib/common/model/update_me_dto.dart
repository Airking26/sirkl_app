// To parse this JSON data, do
//
//     final updateMeDto = updateMeDtoFromJson(jsonString);

import 'dart:convert';

UpdateMeDto updateMeDtoFromJson(String str) =>
    UpdateMeDto.fromJson(json.decode(str));

String updateMeDtoToJson(UpdateMeDto data) => json.encode(data.toJson());

class UpdateMeDto {
  UpdateMeDto(
      {this.userName,
      this.picture,
      this.description,
      this.nicknames,
      this.hasSBT});

  String? userName;
  String? picture;
  String? description;
  bool? hasSBT;
  Map<String, String>? nicknames;

  factory UpdateMeDto.fromJson(Map<String, dynamic> json) => UpdateMeDto(
      userName: json["userName"],
      picture: json["picture"],
      description: json["description"],
      nicknames: json['nicknames'],
      hasSBT: json['hasSBT']);

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "picture": picture,
        "description": description,
        "nicknames": nicknames,
        'hasSBT': hasSBT
      };
}
