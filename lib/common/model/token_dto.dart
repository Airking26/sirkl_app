// To parse this JSON data, do
//
//     final tokenDto = tokenDtoFromJson(jsonString);

import 'dart:convert';

TokenDto tokenDtoFromJson(String str) => TokenDto.fromJson(json.decode(str));

String tokenDtoToJson(TokenDto data) => json.encode(data.toJson());

class TokenDto {
  String? jsonrpc;
  int? id;
  Result? result;

  TokenDto({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) => TokenDto(
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
  String? address;
  List<TokenBalance>? tokenBalances;

  Result({
    this.address,
    this.tokenBalances,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    address: json["address"],
    tokenBalances: json["tokenBalances"] == null ? [] : List<TokenBalance>.from(json["tokenBalances"]!.map((x) => TokenBalance.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "tokenBalances": tokenBalances == null ? [] : List<dynamic>.from(tokenBalances!.map((x) => x.toJson())),
  };
}

class TokenBalance {
  String? contractAddress;
  String? tokenBalance;

  TokenBalance({
    this.contractAddress,
    this.tokenBalance,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) => TokenBalance(
    contractAddress: json["contractAddress"],
    tokenBalance: json["tokenBalance"],
  );

  Map<String, dynamic> toJson() => {
    "contractAddress": contractAddress,
    "tokenBalance": tokenBalance,
  };
}
