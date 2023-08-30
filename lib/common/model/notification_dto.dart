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
    this.title,
    this.message,
    this.channelId,
    this.channelName,
    this.requester,
    this.paying,
    this.inviteId,
    this.channelPrice
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
  String? title;
  String? message;
  String? channelId;
  String? channelName;
  String? requester;
  bool? paying;
  String? inviteId;
  String? channelPrice;

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
    title: json["title"],
    message: json["message"],
    channelId: json["channelId"],
    channelName: json["channelName"],
    requester: json["requester"],
    paying: json['paying'],
    inviteId: json['inviteId'],
    channelPrice: json["channelPrice"]
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
    "title": title,
    "message": message,
    "channelId": channelId,
    "channelName": channelName,
    "requester": requester,
    "paying": paying,
    "inviteId": inviteId,
    "channelPrice": channelPrice
  };
}
