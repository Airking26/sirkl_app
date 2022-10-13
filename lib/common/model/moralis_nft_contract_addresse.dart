// To parse this JSON data, do
//
//     final moralisNftContractAdresses = moralisNftContractAdressesFromJson(jsonString);

import 'dart:convert';

MoralisNftContractAdresses moralisNftContractAdressesFromJson(String str) => MoralisNftContractAdresses.fromJson(json.decode(str));

String moralisNftContractAdressesToJson(MoralisNftContractAdresses data) => json.encode(data.toJson());

class MoralisNftContractAdresses {
  MoralisNftContractAdresses({
    this.status,
    this.total,
    this.page,
    this.pageSize,
    this.cursor,
    this.result,
  });

  String? status;
  int? total;
  int? page;
  int? pageSize;
  String? cursor;
  List<Result>? result;

  factory MoralisNftContractAdresses.fromJson(Map<String, dynamic> json) => MoralisNftContractAdresses(
    status: json["status"],
    total: json["total"],
    page: json["page"],
    pageSize: json["page_size"],
    cursor: json["cursor"],
    result: json["result"] == null ? null : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "total": total,
    "page": page,
    "page_size": pageSize,
    "cursor": cursor,
    "result": result == null ? null : List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  Result({
    this.tokenAddress,
    this.contractType,
    this.name,
    this.symbol,
  });

  String? tokenAddress;
  String? contractType;
  String? name;
  String? symbol;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    tokenAddress: json["token_address"],
    contractType: json["contract_type"],
    name: json["name"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "token_address": tokenAddress,
    "contract_type": contractType,
    "name": name,
    "symbol": symbol,
  };
}
