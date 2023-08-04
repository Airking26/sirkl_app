// To parse this JSON data, do
//
//     final tokenMetadataDetailsDto = tokenMetadataDetailsDtoFromJson(jsonString);

import 'dart:convert';

TokenMetadataDetailsDto tokenMetadataDetailsDtoFromJson(String str) => TokenMetadataDetailsDto.fromJson(json.decode(str));

String tokenMetadataDetailsDtoToJson(TokenMetadataDetailsDto data) => json.encode(data.toJson());

class TokenMetadataDetailsDto {
  String? jsonrpc;
  int? id;
  Result? result;

  TokenMetadataDetailsDto({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory TokenMetadataDetailsDto.fromJson(Map<String, dynamic> json) => TokenMetadataDetailsDto(
    jsonrpc: json["jsonrpc"],
    id: json["id"],
    result: json["result"] == null ? null : Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "jsonrpc": jsonrpc,
    "id": id,
    "result": result?.toJson(),
  };
}

class Result {
  int? decimals;
  String? logo;
  String? name;
  String? symbol;

  Result({
    this.decimals,
    this.logo,
    this.name,
    this.symbol,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    decimals: json["decimals"],
    logo: json["logo"],
    name: json["name"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "decimals": decimals,
    "logo": logo,
    "name": name,
    "symbol": symbol,
  };
}
