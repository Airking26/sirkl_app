import 'package:meta/meta.dart';
import 'dart:convert';

NotificationAddedAdminDto notificationAddedAdminDtoFromJson(String str) => NotificationAddedAdminDto.fromJson(json.decode(str));

String notificationAddedAdminDtoToJson(NotificationAddedAdminDto data) => json.encode(data.toJson());

class NotificationAddedAdminDto {
  NotificationAddedAdminDto({
    required this.idUser,
    required this.idChannel,
    required this.channelName,
    this.channelPrice,
    this.channelPrivate,
    this.inviteId
  });

  String idUser;
  String idChannel;
  String channelName;
  String? channelPrice;
  bool? channelPrivate;
  String? inviteId;

  factory NotificationAddedAdminDto.fromJson(Map<String, dynamic> json) => NotificationAddedAdminDto(
    idUser: json["idUser"],
    idChannel: json["idChannel"],
    channelName: json["channelName"],
    channelPrice: json["channelPrice"],
    channelPrivate: json["channelPrivate"],
    inviteId: json["inviteId"]
  );

  Map<String, dynamic> toJson() => {
    "idUser": idUser,
    "idChannel": idChannel,
    "channelName": channelName,
    "channelPrice": channelPrice,
    "channelPrivate": channelPrivate,
    "inviteId": inviteId
  };
}
