// To parse this JSON data, do
//
//     final inboxDto = inboxDtoFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

InboxDto inboxDtoFromJson(String str) => InboxDto.fromJson(json.decode(str));

String inboxDtoToJson(InboxDto data) => json.encode(data.toJson());

class InboxDto {
  InboxDto({
    required this.id,
    required this.lastMessage,
    required this.lastSender,
    required this.unreadMessages,
    required this.updatedAt,
    required this.ownedBy,
  });

  String id;
  String lastMessage;
  String lastSender;
  int unreadMessages;
  DateTime updatedAt;
  List<OwnedBy> ownedBy;

  factory InboxDto.fromJson(Map<String, dynamic> json) => InboxDto(
    id: json["id"],
    lastMessage: json["lastMessage"],
    lastSender: json["lastSender"],
    unreadMessages: json["unreadMessages"],
    updatedAt: DateTime.parse(json["updatedAt"]),
    ownedBy: List<OwnedBy>.from(json["ownedBy"].map((x) => OwnedBy.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lastMessage": lastMessage,
    "lastSender": lastSender,
    "unreadMessages": unreadMessages,
    "updatedAt": updatedAt.toIso8601String(),
    "ownedBy": List<dynamic>.from(ownedBy.map((x) => x.toJson())),
  };
}

class OwnedBy {
  OwnedBy({
    this.id,
    this.userName,
    this.picture,
    this.isAdmin,
    this.createdAt,
    this.description,
    this.fcmToken,
    this.wallet,
    this.contractAddresses,
    this.following,
    this.isInFollowing,
  });

  String? id;
  String? userName;
  String? picture;
  bool? isAdmin;
  DateTime? createdAt;
  String? description;
  String? fcmToken;
  String? wallet;
  List<String>? contractAddresses;
  int? following;
  bool? isInFollowing;

  factory OwnedBy.fromJson(Map<String, dynamic> json) => OwnedBy(
    id: json["id"],
    userName: json["userName"],
    picture: json["picture"],
    isAdmin: json["isAdmin"],
    createdAt: DateTime.parse(json["createdAt"]),
    description: json["description"],
    fcmToken: json["fcmToken"],
    wallet: json["wallet"],
    contractAddresses: List<String>.from(json["contractAddresses"].map((x) => x)),
    following: json["following"],
    isInFollowing: json["isInFollowing"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userName": userName,
    "picture": picture,
    "isAdmin": isAdmin,
    "createdAt": createdAt?.toIso8601String(),
    "description": description,
    "fcmToken": fcmToken,
    "wallet": wallet,
    "contractAddresses": List<dynamic>.from(contractAddresses!.map((x) => x)),
    "following": following,
    "isInFollowing": isInFollowing,
  };
}
