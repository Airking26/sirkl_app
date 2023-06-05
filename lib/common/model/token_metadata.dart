import 'dart:convert';

TokenMetadataDTO tokenMetadataFromJson(String str) => TokenMetadataDTO.fromJson(json.decode(str));

String tokenMetadataToJson(TokenMetadataDTO data) => json.encode(data.toJson());

class TokenMetadataDTO {
  String? jsonrpc;
  int? id;
  Result? result;

  TokenMetadataDTO({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory TokenMetadataDTO.fromJson(Map<String, dynamic> json) => TokenMetadataDTO(
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