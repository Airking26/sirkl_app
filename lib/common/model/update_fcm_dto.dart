import 'dart:convert';

UpdateFcmdto updateFcmdtoFromJson(String str) =>
    UpdateFcmdto.fromJson(json.decode(str));

String updateFcmdtoToJson(UpdateFcmdto data) => json.encode(data.toJson());

class UpdateFcmdto {
  UpdateFcmdto({
    this.token,
    this.platform,
  });

  String? token;
  String? platform;

  factory UpdateFcmdto.fromJson(Map<String, dynamic> json) => UpdateFcmdto(
        token: json["token"],
        platform: json["platform"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "platform": platform,
      };
}
