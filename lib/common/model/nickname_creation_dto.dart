import 'dart:convert';

NicknameCreationDto nicknameCreationDtoFromJson(String str) =>
    NicknameCreationDto.fromJson(json.decode(str));

String nicknameCreationDtoToJson(NicknameCreationDto data) =>
    json.encode(data.toJson());

class NicknameCreationDto {
  NicknameCreationDto({
    required this.nickname,
  });

  String nickname;

  factory NicknameCreationDto.fromJson(Map<String, dynamic> json) =>
      NicknameCreationDto(
        nickname: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
      };
}
