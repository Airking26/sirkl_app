// To parse this JSON data, do
//
//     final inboxDto = inboxDtoFromJson(jsonString);
import 'dart:convert';

import 'package:sirkl/common/model/sign_in_success_dto.dart';

InboxDto inboxDtoFromJson(String str) => InboxDto.fromJson(json.decode(str));

String inboxDtoToJson(InboxDto data) => json.encode(data.toJson());

class InboxDto {
  InboxDto({
    this.id,
    this.lastMessage,
    this.lastSender,
    this.unreadMessages,
    this.updatedAt,
    this.ownedBy,
  });

  String? id;
  String? lastMessage;
  String? lastSender;
  int? unreadMessages;
  DateTime? updatedAt;
  List<UserDTO>? ownedBy;

  factory InboxDto.fromJson(Map<String, dynamic> json) => InboxDto(
        id: json["id"],
        lastMessage: json["lastMessage"],
        lastSender: json["lastSender"],
        unreadMessages: json["unreadMessages"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        ownedBy:
            List<UserDTO>.from(json["ownedBy"].map((x) => UserDTO.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastMessage": lastMessage,
        "lastSender": lastSender,
        "unreadMessages": unreadMessages,
        "updatedAt": updatedAt!.toIso8601String(),
        "ownedBy": List<dynamic>.from(ownedBy!.map((x) => x.toJson())),
      };
}
