import 'dart:convert';

InboxModificationDto inboxModificationDtoFromJson(String str) =>
    InboxModificationDto.fromJson(json.decode(str));

String inboxModificationDtoToJson(InboxModificationDto data) =>
    json.encode(data.toJson());

class InboxModificationDto {
  InboxModificationDto({
    this.lastSender,
    this.unreadMessages,
    this.lastMessage,
  });

  String? lastSender;
  int? unreadMessages;
  String? lastMessage;

  factory InboxModificationDto.fromJson(Map<String, dynamic> json) =>
      InboxModificationDto(
        lastSender: json["lastSender"],
        unreadMessages: json["unreadMessages"],
        lastMessage: json["lastMessage"],
      );

  Map<String, dynamic> toJson() => {
        "lastSender": lastSender,
        "unreadMessages": unreadMessages,
        "lastMessage": lastMessage,
      };
}
