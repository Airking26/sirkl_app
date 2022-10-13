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
    this.contractAddresses
  });

  String? userName;
  String? picture;
  String? description;
  List<String>? contractAddresses;

  factory UpdateMeDto.fromJson(Map<String, dynamic> json) => UpdateMeDto(
    userName: json["userName"],
    picture: json["picture"],
    description: json["description"],
    contractAddresses: json["contractAddresses"] == null ? null : List<String>.from(json["contractAddresses"].map((x) => x))
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "picture": picture,
    "description": description,
    "contractAddresses": contractAddresses == null ? null : List<dynamic>.from(contractAddresses!.map((x) => x)),
  };
}
