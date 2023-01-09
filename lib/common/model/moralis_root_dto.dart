import 'dart:convert';

import 'package:sirkl/common/model/moralis_metadata_dto.dart';

MoralisRootDto moralisRootDtoFromJson(String str) => MoralisRootDto.fromJson(json.decode(str));

String moralisRootDtoToJson(MoralisRootDto data) => json.encode(data.toJson());

class MoralisRootDto {
  MoralisRootDto({
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
  List<Result?>? result;

  factory MoralisRootDto.fromJson(Map<String, dynamic> json) => MoralisRootDto(
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
    "result": result == null ? null : List<dynamic>.from(result!.map((x) => x!.toJson())),
  };
}

class Result {
  Result({
    this.tokenAddress,
    this.tokenId,
    this.contractType,
    this.ownerOf,
    this.blockNumber,
    this.blockNumberMinted,
    this.tokenUri,
    this.normalizedMetadata,
    this.amount,
    this.name,
    this.symbol,
    this.tokenHash,
    this.lastTokenUriSync,
    this.lastMetadataSync,
  });

  String? tokenAddress;
  String? tokenId;
  String? contractType;
  String? ownerOf;
  String? blockNumber;
  String? blockNumberMinted;
  String? tokenUri;
  NormalizedMetadata? normalizedMetadata;
  String? amount;
  String? name;
  String? symbol;
  String? tokenHash;
  String? lastTokenUriSync;
  String? lastMetadataSync;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    tokenAddress: json["token_address"],
    tokenId: json["token_id"],
    contractType: json["contract_type"],
    ownerOf: json["owner_of"],
    blockNumber: json["block_number"],
    blockNumberMinted: json["block_number_minted"],
    tokenUri: json["token_uri"],
    normalizedMetadata: json["normalized_metadata"] == null ? null : NormalizedMetadata.fromJson(json["normalized_metadata"]),
    amount: json["amount"],
    name: json["name"],
    symbol: json["symbol"],
    tokenHash: json["token_hash"],
    lastTokenUriSync: json["last_token_uri_sync"],
    lastMetadataSync: json["last_metadata_sync"],
  );

  Map<String, dynamic> toJson() => {
    "token_address": tokenAddress,
    "token_id": tokenId,
    "contract_type": contractType,
    "owner_of": ownerOf,
    "block_number": blockNumber,
    "block_number_minted": blockNumberMinted,
    "token_uri": tokenUri,
    "normalizedMetadata": normalizedMetadata?.toJson(),
    "amount": amount,
    "name": name,
    "symbol": symbol,
    "token_hash": tokenHash,
    "last_token_uri_sync": lastTokenUriSync,
    "last_metadata_sync": lastMetadataSync,
  };
}

class NormalizedMetadata {
  NormalizedMetadata({
    this.name,
    this.description,
    this.image,
    this.externalLink,
    this.animationUrl,
    this.attributes,
  });

  String? name;
  String? description;
  dynamic image;
  dynamic externalLink;
  dynamic animationUrl;
  List<dynamic>? attributes;

  factory NormalizedMetadata.fromJson(Map<String, dynamic> json) => NormalizedMetadata(
    name: json["name"] == null ? null : json["name"],
    description: json["description"] == null ? null : json["description"],
    image: json["image"],
    externalLink: json["external_link"],
    animationUrl: json["animation_url"],
    attributes: json["attributes"] == null ? null : List<dynamic>.from(json["attributes"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "description": description == null ? null : description,
    "image": image,
    "external_link": externalLink,
    "animation_url": animationUrl,
    "attributes": attributes == null ? null : List<dynamic>.from(attributes!.map((x) => x)),
  };
}
