import 'package:meta/meta.dart';
import 'dart:convert';

InboxCreationDto inboxCreationDtoFromJson(String str) => InboxCreationDto.fromJson(json.decode(str));

String inboxCreationDtoToJson(InboxCreationDto data) => json.encode(data.toJson());

class InboxCreationDto {
  InboxCreationDto({
    required this.lastMessage,
    required this.updatedAt,
    required this.lastSender,
    required this.unreadMessages,
    required this.ownedBy,
  });

  String lastMessage;
  DateTime updatedAt;
  String lastSender;
  int unreadMessages;
  List<String> ownedBy;

  factory InboxCreationDto.fromJson(Map<String, dynamic> json) => InboxCreationDto(
    lastMessage: json["lastMessage"],
    updatedAt: DateTime.parse(json["updatedAt"]),
    lastSender: json["lastSender"],
    unreadMessages: json["unreadMessages"],
    ownedBy: List<String>.from(json["ownedBy"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "lastMessage": lastMessage,
    "updatedAt": updatedAt.toIso8601String(),
    "lastSender": lastSender,
    "unreadMessages": unreadMessages,
    "ownedBy": List<dynamic>.from(ownedBy.map((x) => x)),
  };
}
