import 'dart:convert';

CallModificationDto callModificationDtoFromJson(String str) =>
    CallModificationDto.fromJson(json.decode(str));

String callModificationDtoToJson(CallModificationDto data) =>
    json.encode(data.toJson());

class CallModificationDto {
  CallModificationDto({
    required this.id,
    required this.status,
    required this.updatedAt,
  });

  String id;
  int status;
  DateTime updatedAt;

  factory CallModificationDto.fromJson(Map<String, dynamic> json) =>
      CallModificationDto(
        id: json["id"],
        status: json["status"],
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "updatedAt": updatedAt.toIso8601String(),
      };
}
