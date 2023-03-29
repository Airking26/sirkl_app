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
    required this.message,
    required this.isConv,
    this.nameOfGroup,
    this.picOfGroup,
    this.members
  });

  String createdBy;
  String idChannel;
  String message;
  bool isConv;
  String? nameOfGroup;
  String? picOfGroup;
  List<String>? members;
  List<String> wallets;

  factory InboxCreationDto.fromJson(Map<String, dynamic> json) => InboxCreationDto(
    createdBy: json["createdBy"],
    idChannel: json["idChannel"],
    message: json["message"],
    isConv: json["isConv"],
    nameOfGroup: json["nameOfGroup"],
    picOfGroup: json["picOfGroup"],
    members: json["members"] == null ? null : List<String>.from(json["members"].map((x) => x)),
    wallets: List<String>.from(json["wallets"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "idChannel": idChannel,
    "message": message,
    "isConv": isConv,
    "picOfGroup": picOfGroup,
    "nameOfGroup": nameOfGroup,
    "wallets": List<dynamic>.from(wallets.map((x) => x)),
    "members": members == null ? null : List<dynamic>.from(members!.map((x) => x)),
  };
}
