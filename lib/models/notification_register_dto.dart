import 'dart:convert';

NotificationRegisterDto notificationRegisterDtoFromJson(String str) =>
    NotificationRegisterDto.fromJson(json.decode(str));

String notificationRegisterDtoToJson(NotificationRegisterDto data) =>
    json.encode(data.toJson());

class NotificationRegisterDto {
  NotificationRegisterDto({
    required this.message,
  });

  String message;

  factory NotificationRegisterDto.fromJson(Map<String, dynamic> json) =>
      NotificationRegisterDto(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
