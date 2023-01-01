import 'package:meta/meta.dart';
import 'dart:convert';

CallCreationDto callCreationDtoFromJson(String str) => CallCreationDto.fromJson(json.decode(str));

String callCreationDtoToJson(CallCreationDto data) => json.encode(data.toJson());

class CallCreationDto {
  CallCreationDto({
    required this.updatedAt,
    required this.called,
    required this.status,
    required this.channel,
  });

  DateTime updatedAt;
  String called;
  int status;
  String channel;

  factory CallCreationDto.fromJson(Map<String, dynamic> json) => CallCreationDto(
    updatedAt: DateTime.parse(json["updatedAt"]),
    called: json["called"],
    status: json["status"],
    channel: json["channel"],
  );

  Map<String, dynamic> toJson() => {
    "updatedAt": updatedAt.toIso8601String(),
    "called": called,
    "status": status,
    "channel": channel,
  };
}
