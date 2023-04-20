import 'package:meta/meta.dart';
import 'dart:convert';

NotificationAddedAdminDto notificationAddedAdminDtoFromJson(String str) => NotificationAddedAdminDto.fromJson(json.decode(str));

String notificationAddedAdminDtoToJson(NotificationAddedAdminDto data) => json.encode(data.toJson());

class NotificationAddedAdminDto {
  NotificationAddedAdminDto({
    required this.idUser,
    required this.idChannel,
    required this.channelName,
  });

  String idUser;
  String idChannel;
  String channelName;

  factory NotificationAddedAdminDto.fromJson(Map<String, dynamic> json) => NotificationAddedAdminDto(
    idUser: json["idUser"],
    idChannel: json["idChannel"],
    channelName: json["channelName"],
  );

  Map<String, dynamic> toJson() => {
    "idUser": idUser,
    "idChannel": idChannel,
    "channelName": channelName,
  };
}
