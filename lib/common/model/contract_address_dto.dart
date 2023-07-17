// To parse this JSON data, do
//
//     final contractAddressDto = contractAddressDtoFromJson(jsonString);

import 'dart:convert';

import 'package:sirkl/common/model/nft_alchemy_dto.dart';

ContractAddressDto contractAddressDtoFromJson(String str) => ContractAddressDto.fromJson(json.decode(str));

String contractAddressDtoToJson(ContractAddressDto data) => json.encode(data.toJson());

class ContractAddressDto {
  ContractAddressDto({
    required this.contracts,
    this.totalCount,
    this.pageKey,
  });

  List<Contract> contracts;
  int? totalCount;
  String? pageKey;

  factory ContractAddressDto.fromJson(Map<String, dynamic> json) => ContractAddressDto(
    contracts: json["contracts"] == null ? [] : List<Contract>.from(json["contracts"]!.map((x) => Contract.fromJson(x))),
    totalCount: json["totalCount"],
    pageKey: json["pageKey"],
  );

  Map<String, dynamic> toJson() => {
    "contracts": contracts == null ? [] : List<dynamic>.from(contracts!.map((x) => x.toJson())),
    "totalCount": totalCount,
    "pageKey": pageKey,
  };
}

class Contract {
  Contract({
    this.address,
    this.totalBalance,
    this.numDistinctTokensOwned,
    this.isSpam,
    this.tokenId,
    this.name,
    this.title,
    this.symbol,
    this.tokenType,
    this.contractDeployer,
    this.deployedBlockNumber,
    this.opensea,
    this.media,
  });

  String? address;
  int? totalBalance;
  int? numDistinctTokensOwned;
  bool? isSpam;
  String? tokenId;
  String? name;
  String? title;
  String? symbol;
  TokenType? tokenType;
  String? contractDeployer;
  int? deployedBlockNumber;
  Opensea? opensea;
  List<Media>? media;

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    address: json["address"],
    totalBalance: json["totalBalance"],
    numDistinctTokensOwned: json["numDistinctTokensOwned"],
    isSpam: json["isSpam"],
    tokenId: json["tokenId"],
    name: json["name"],
    title: json["title"],
    symbol: json["symbol"],
    tokenType: json["tokenType"] == null ? null : tokenTypeValues.map[json["tokenType"]],
    contractDeployer: json["contractDeployer"],
    deployedBlockNumber: json["deployedBlockNumber"],
    opensea: json["opensea"] == null ? null : Opensea.fromJson(json["opensea"]),
    media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "totalBalance": totalBalance,
    "numDistinctTokensOwned": numDistinctTokensOwned,
    "isSpam": isSpam,
    "tokenId": tokenId,
    "name": name,
    "title": title,
    "symbol": symbol,
    "tokenType": tokenType == null ? null : tokenTypeValues.reverse[tokenType],
    "contractDeployer": contractDeployer,
    "deployedBlockNumber": deployedBlockNumber,
    "opensea": opensea?.toJson(),
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
  };
}

class Media {
  Media({
    this.raw,
    this.gateway,
    this.thumbnail
  });

  String? raw;
  String? gateway;
  String? thumbnail;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    raw: json["raw"],
    gateway: json["gateway"],
    thumbnail: json["thumbnail"]
  );

  Map<String, dynamic> toJson() => {
    "raw": raw,
    "gateway": gateway,
    "thumbnail": thumbnail,
  };
}

class Opensea {
  Opensea({
    this.collectionName,
    this.safelistRequestStatus,
    this.imageUrl,
    this.description,
    this.externalUrl,
    this.lastIngestedAt,
  });

  String? collectionName;
  SafelistRequestStatus? safelistRequestStatus;
  String? imageUrl;
  String? description;
  String? externalUrl;
  DateTime? lastIngestedAt;

  factory Opensea.fromJson(Map<String, dynamic> json) => Opensea(
    collectionName: json["collectionName"],
    safelistRequestStatus: json["safelistRequestStatus"] == null ? null : safelistRequestStatusValues.map[json["safelistRequestStatus"]],
    imageUrl: json["imageUrl"],
    description: json["description"],
    externalUrl: json["externalUrl"],
    lastIngestedAt: json["lastIngestedAt"] == null ? null : DateTime.parse(json["lastIngestedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "collectionName": collectionName,
    "safelistRequestStatus": safelistRequestStatus == null ? null : safelistRequestStatusValues.reverse[safelistRequestStatus],
    "imageUrl": imageUrl,
    "description": description,
    "externalUrl": externalUrl,
    "lastIngestedAt": lastIngestedAt?.toIso8601String(),
  };
}
