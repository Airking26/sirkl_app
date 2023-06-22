import 'dart:ffi';

import 'package:meta/meta.dart';
import 'dart:convert';

InboxCreationDto inboxCreationDtoFromJson(String str) => InboxCreationDto.fromJson(json.decode(str));

String inboxCreationDtoToJson(InboxCreationDto data) => json.encode(data.toJson());

List<InboxCreationDto> inboxCreationListDtoFromJson(String str) => List<InboxCreationDto>.from(json.decode(str).map((x) => InboxCreationDto.fromJson(x)));
String inboxCreationListDtoToJson(List<InboxCreationDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InboxCreationDto {
  InboxCreationDto({
    required this.createdBy,
    required this.wallets,
    required this.idChannel,
    required this.isConv,
    this.message,
    this.nameOfGroup,
    this.picOfGroup,
    this.members,
    this.isGroupPrivate,
    this.isGroupVisible,
    this.isGroupPaying,
    this.price,
    this.tokenAccepted,
    this.idGroupBlockchain
  });

  String createdBy;
  String idChannel;
  String? message;
  bool isConv;
  String? nameOfGroup;
  String? picOfGroup;
  List<String>? members;
  List<String> wallets;
  bool? isGroupPrivate;
  bool? isGroupVisible;
  bool? isGroupPaying;
  double? price;
  String? tokenAccepted;
  String? idGroupBlockchain;

  factory InboxCreationDto.fromJson(Map<String, dynamic> json) => InboxCreationDto(
    createdBy: json["createdBy"],
    idChannel: json["idChannel"],
    message: json["message"],
    isConv: json["isConv"],
    nameOfGroup: json["nameOfGroup"],
    isGroupPrivate: json["isGroupPrivate"],
    isGroupVisible: json["isGroupVisible"],
    isGroupPaying: json["isGroupPaying"],
    picOfGroup: json["picOfGroup"],
    price: json["price"],
    tokenAccepted: json["tokenAccepted"],
    idGroupBlockchain: json["idGroupBlockchain"],
    members: json["members"] == null ? null : List<String>.from(json["members"].map((x) => x)),
    wallets: List<String>.from(json["wallets"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "idChannel": idChannel,
    "message": message,
    "isConv": isConv,
    "isGroupPrivate": isGroupPrivate,
    "isGroupVisible": isGroupVisible,
    "isGroupPaying": isGroupPaying,
    "picOfGroup": picOfGroup,
   // "price": price,
    "tokenAccepted": tokenAccepted,
    "idGroupBlockchain": idGroupBlockchain,
    "nameOfGroup": nameOfGroup,
    "wallets": List<dynamic>.from(wallets.map((x) => x)),
    "members": members == null ? null : List<dynamic>.from(members!.map((x) => x)),
  };
}
