import 'dart:convert';

RefreshTokenDto refreshTokenDtoFromJson(String str) => RefreshTokenDto.fromJson(json.decode(str));

String refreshTokenDtoToJson(RefreshTokenDto data) => json.encode(data.toJson());

class RefreshTokenDto {
  RefreshTokenDto({
    this.accessToken,
  });

  String? accessToken;

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) => RefreshTokenDto(
    accessToken: json["accessToken"],
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
  };
}
