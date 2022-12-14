import 'dart:convert';

List<NotificationDto> notificationDtoFromJson(String str) => List<NotificationDto>.from(json.decode(str).map((x) => NotificationDto.fromJson(x)));

String notificationDtoToJson(List<NotificationDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationDto {
  NotificationDto({
    required this.id,
    required this.createdAt,
    required this.hasBeenRead,
    this.picture,
    required this.type,
    required this.belongTo,
    this.username,
    this.wallet,
    required this.idData,
    this.eventName,
  });

  String id;
  DateTime createdAt;
  bool hasBeenRead;
  String? picture;
  int type;
  String belongTo;
  String? username;
  String? wallet;
  String idData;
  String? eventName;

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
    id: json["id"],
    createdAt: DateTime.parse(json["createdAt"]),
    hasBeenRead: json["hasBeenRead"],
    picture: json["picture"],
    type: json["type"],
    belongTo: json["belongTo"],
    username: json["username"],
    wallet: json["wallet"],
    idData: json["idData"],
    eventName: json["eventName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt.toIso8601String(),
    "hasBeenRead": hasBeenRead,
    "picture": picture,
    "type": type,
    "belongTo": belongTo,
    "username": username,
    "wallet": wallet,
    "idData": idData,
    "eventName": eventName,
  };
}
