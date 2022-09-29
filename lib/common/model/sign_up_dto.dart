import 'dart:convert';

SignUpDto signUpDtoFromJson(String str) => SignUpDto.fromJson(json.decode(str));

String signUpDtoToJson(SignUpDto data) => json.encode(data.toJson());

class SignUpDto {
  SignUpDto({
    required this.wallet,
    required this.password,
    required this.recoverySentence,
  });

  String? wallet;
  String? recoverySentence;
  String? password;

  factory SignUpDto.fromJson(Map<String, dynamic> json) => SignUpDto(
    wallet: json["wallet"],
    recoverySentence: json["recoverySentence"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "wallet": wallet,
    "recoverySentence": recoverySentence,
    "password": password,
  };
}
