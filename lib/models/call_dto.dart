// To parse this JSON data, do
//
//     final callDto = callDtoFromJson(jsonString);

import 'dart:convert';

import 'package:sirkl/models/sign_in_success_dto.dart';


List<CallDto> callDtoFromJson(String str) =>
    List<CallDto>.from(json.decode(str).map((x) => CallDto.fromJson(x)));

String callDtoToJson(List<CallDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CallDto {
  CallDto({
    required this.id,
    required this.called,
    required this.updatedAt,
    required this.status,
  });

  String id;
  UserDTO called;
  DateTime updatedAt;
  int status;

  factory CallDto.fromJson(Map<String, dynamic> json) => CallDto(
        id: json["id"],
        called: UserDTO.fromJson(json["called"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "called": called.toJson(),
        "updatedAt": updatedAt.toIso8601String(),
        "status": status,
      };
}
