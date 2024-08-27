import 'dart:convert';

SignInDto signInDtoFromJson(String str) => SignInDto.fromJson(json.decode(str));

String signInDtoToJson(SignInDto data) => json.encode(data.toJson());

class SignInDto {
  SignInDto({
    required this.wallet,
    required this.password,
  });

  String? wallet;
  String? password;

  factory SignInDto.fromJson(Map<String, dynamic> json) => SignInDto(
        wallet: json["wallet"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "wallet": wallet,
        "password": password,
      };
}
