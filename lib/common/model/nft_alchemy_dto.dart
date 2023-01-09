import 'dart:convert';

NftAlchemyDto nftAlchemyDtoFromJson(String str) => NftAlchemyDto.fromJson(json.decode(str));

String nftAlchemyDtoToJson(NftAlchemyDto data) => json.encode(data.toJson());

class NftAlchemyDto {
  NftAlchemyDto({
    this.ownedNfts,
    this.pageKey,
    this.totalCount,
    this.blockHash,
  });

  List<OwnedNft>? ownedNfts;
  String? pageKey;
  int? totalCount;
  String? blockHash;

  factory NftAlchemyDto.fromJson(Map<String, dynamic> json) => NftAlchemyDto(
    ownedNfts: json["ownedNfts"] == null ? null : List<OwnedNft>.from(json["ownedNfts"].map((x) => OwnedNft.fromJson(x))),
    pageKey: json["pageKey"],
    totalCount: json["totalCount"],
    blockHash: json["blockHash"],
  );

  Map<String, dynamic> toJson() => {
    "ownedNfts": ownedNfts == null ? null : List<dynamic>.from(ownedNfts!.map((x) => x.toJson())),
    "pageKey": pageKey,
    "totalCount": totalCount,
    "blockHash": blockHash,
  };
}

class OwnedNft {
  OwnedNft({
    this.contract,
    this.id,
    this.balance,
    this.title,
    this.description,
    this.tokenUri,
    this.media,
    this.metadata,
    this.timeLastUpdated,
    this.contractMetadata,
    this.error,
  });

  Contract? contract;
  Id? id;
  String? balance;
  String? title;
  String? description;
  TokenUri? tokenUri;
  List<Media>? media;
  Metadata? metadata;
  DateTime? timeLastUpdated;
  ContractMetadata? contractMetadata;
  String? error;

  factory OwnedNft.fromJson(Map<String, dynamic> json) => OwnedNft(
    contract: json["contract"] == null ? null : Contract.fromJson(json["contract"]),
    id: json["id"] == null ? null : Id.fromJson(json["id"]),
    balance: json["balance"],
    title: json["title"],
    description: json["description"],
    tokenUri: json["tokenUri"] == null ? null : TokenUri.fromJson(json["tokenUri"]),
    media: json["media"] == null ? null : List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
    metadata: null,
    timeLastUpdated: json["timeLastUpdated"] == null ? null : DateTime.parse(json["timeLastUpdated"]),
    contractMetadata: json["contractMetadata"] == null ? null : ContractMetadata.fromJson(json["contractMetadata"]),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "contract": contract == null ? null : contract?.toJson(),
    "id": id == null ? null : id?.toJson(),
    "balance": balance,
    "title": title,
    "description": description,
    "tokenUri": tokenUri == null ? null : tokenUri?.toJson(),
    "media": media == null ? null : List<dynamic>.from(media!.map((x) => x.toJson())),
    "metadata": metadata == null ? null : metadata?.toJson(),
    "timeLastUpdated": timeLastUpdated == null ? null : timeLastUpdated?.toIso8601String(),
    "contractMetadata": contractMetadata == null ? null : contractMetadata?.toJson(),
    "error": error,
  };
}

class Contract {
  Contract({
    this.address,
  });

  String? address;

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
  };
}

class ContractMetadata {
  ContractMetadata({
    this.name,
    this.symbol,
    this.tokenType,
    this.contractDeployer,
    this.deployedBlockNumber,
    this.openSea,
    this.totalSupply,
  });

  String? name;
  String? symbol;
  TokenType? tokenType;
  String? contractDeployer;
  int? deployedBlockNumber;
  OpenSea? openSea;
  String? totalSupply;

  factory ContractMetadata.fromJson(Map<String, dynamic> json) => ContractMetadata(
    name: json["name"],
    symbol: json["symbol"],
    tokenType: json["tokenType"] == null ? null : tokenTypeValues.map[json["tokenType"]],
    contractDeployer: json["contractDeployer"],
    deployedBlockNumber: json["deployedBlockNumber"],
    openSea: json["openSea"] == null ? null : OpenSea.fromJson(json["openSea"]),
    totalSupply: json["totalSupply"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "symbol": symbol,
    "tokenType": tokenType == null ? null : tokenTypeValues.reverse[tokenType],
    "contractDeployer": contractDeployer,
    "deployedBlockNumber": deployedBlockNumber,
    "openSea": openSea == null ? null : openSea?.toJson(),
    "totalSupply": totalSupply,
  };
}

class OpenSea {
  OpenSea({
    this.collectionName,
    this.safelistRequestStatus,
    this.imageUrl,
    this.description,
    this.externalUrl,
    this.lastIngestedAt,
    this.discordUrl,
    this.floorPrice,
    this.twitterUsername,
  });

  String? collectionName;
  SafelistRequestStatus? safelistRequestStatus;
  String? imageUrl;
  String? description;
  String? externalUrl;
  DateTime? lastIngestedAt;
  String? discordUrl;
  double? floorPrice;
  String? twitterUsername;

  factory OpenSea.fromJson(Map<String, dynamic> json) => OpenSea(
    collectionName: json["collectionName"],
    safelistRequestStatus: json["safelistRequestStatus"] == null ? null : safelistRequestStatusValues.map[json["safelistRequestStatus"]],
    imageUrl: json["imageUrl"],
    description: json["description"],
    externalUrl: json["externalUrl"],
    lastIngestedAt: json["lastIngestedAt"] == null ? null : DateTime.parse(json["lastIngestedAt"]),
    discordUrl: json["discordUrl"],
    floorPrice: json["floorPrice"] == null ? null : json["floorPrice"].toDouble(),
    twitterUsername: json["twitterUsername"],
  );

  Map<String, dynamic> toJson() => {
    "collectionName": collectionName,
    "safelistRequestStatus": safelistRequestStatus == null ? null : safelistRequestStatusValues.reverse[safelistRequestStatus],
    "imageUrl": imageUrl,
    "description": description,
    "externalUrl": externalUrl,
    "lastIngestedAt": lastIngestedAt == null ? null : lastIngestedAt?.toIso8601String(),
    "discordUrl": discordUrl,
    "floorPrice": floorPrice,
    "twitterUsername": twitterUsername,
  };
}

enum SafelistRequestStatus { NOT_REQUESTED, APPROVED, VERIFIED }

final safelistRequestStatusValues = EnumValues({
  "approved": SafelistRequestStatus.APPROVED,
  "not_requested": SafelistRequestStatus.NOT_REQUESTED,
  "verified": SafelistRequestStatus.VERIFIED
});

enum TokenType { ERC1155, ERC721, UNKNOWN }

final tokenTypeValues = EnumValues({
  "ERC1155": TokenType.ERC1155,
  "ERC721": TokenType.ERC721,
  "UNKNOWN": TokenType.UNKNOWN
});

class Id {
  Id({
    this.tokenId,
    this.tokenMetadata,
  });

  String? tokenId;
  TokenMetadata? tokenMetadata;

  factory Id.fromJson(Map<String, dynamic> json) => Id(
    tokenId: json["tokenId"],
    tokenMetadata: json["tokenMetadata"] == null ? null : TokenMetadata.fromJson(json["tokenMetadata"]),
  );

  Map<String, dynamic> toJson() => {
    "tokenId": tokenId,
    "tokenMetadata": tokenMetadata == null ? null : tokenMetadata?.toJson(),
  };
}

class TokenMetadata {
  TokenMetadata({
    this.tokenType,
  });

  TokenType? tokenType;

  factory TokenMetadata.fromJson(Map<String, dynamic> json) => TokenMetadata(
    tokenType: json["tokenType"] == null ? null : tokenTypeValues.map[json["tokenType"]],
  );

  Map<String, dynamic> toJson() => {
    "tokenType": tokenType == null ? null : tokenTypeValues.reverse[tokenType],
  };
}

class Media {
  Media({
    this.raw,
    this.gateway,
    this.thumbnail,
    this.format,
    this.bytes,
  });

  String? raw;
  String? gateway;
  String? thumbnail;
  Format? format;
  int? bytes;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    raw: json["raw"],
    gateway: json["gateway"],
    thumbnail: json["thumbnail"],
    format: json["format"] == null ? null : formatValues.map[json["format"]],
    bytes: json["bytes"],
  );

  Map<String, dynamic> toJson() => {
    "raw": raw,
    "gateway": gateway,
    "thumbnail": thumbnail,
    "format": format == null ? null : formatValues.reverse[format],
    "bytes": bytes,
  };
}

enum Format { PNG, JPEG, SVG_XML, WEBP, GIF, MP4 }

final formatValues = EnumValues({
  "gif": Format.GIF,
  "jpeg": Format.JPEG,
  "mp4": Format.MP4,
  "png": Format.PNG,
  "svg+xml": Format.SVG_XML,
  "webp": Format.WEBP
});

class Metadata {
  Metadata({
    this.name,
    this.description,
    this.image,
    this.attributes,
    this.externalLink,
    this.externalUrl,
    this.dna,
    this.edition,
    this.compiler,
    this.metadata,
    this.date,
    this.id,
    this.collection,
    this.objectId,
    this.animationUrl,
    this.contract,
    this.symbol,
    this.backgroundColor,
    this.backgroundImage,
    this.isNormalized,
    this.segmentLength,
    this.imageUrl,
    this.nameLength,
    this.version,
    this.url,
    this.sellerFeeBasisPoints,
    this.feeRecipient,
    this.youtubeUrl,
  });

  String? name;
  String? description;
  String? image;
  List<Attribute>? attributes;
  String? externalLink;
  String? externalUrl;
  String? dna;
  int? edition;
  String? compiler;
  List<dynamic>? metadata;
  int? date;
  int? id;
  String? collection;
  String? objectId;
  String? animationUrl;
  String? contract;
  String? symbol;
  String? backgroundColor;
  String? backgroundImage;
  bool? isNormalized;
  int? segmentLength;
  String? imageUrl;
  int? nameLength;
  int? version;
  String? url;
  int? sellerFeeBasisPoints;
  String? feeRecipient;
  String? youtubeUrl;

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    name: json["name"],
    description: json["description"],
    image: json["image"],
    attributes: json["attributes"] == null ? null : List<Attribute>.from(json["attributes"].map((x) => Attribute.fromJson(x))),
    externalLink: json["external_link"],
    externalUrl: json["external_url"],
    dna: json["dna"],
    edition: json["edition"],
    compiler: json["compiler"],
    metadata: json["metadata"] == null ? null : List<dynamic>.from(json["metadata"].map((x) => x)),
    date: json["date"],
    id: json["id"],
    collection: json["collection"],
    objectId: json["objectID"],
    animationUrl: json["animation_url"],
    contract: json["contract"],
    symbol: json["symbol"],
    backgroundColor: json["background_color"],
    backgroundImage: json["background_image"],
    isNormalized: json["is_normalized"],
    segmentLength: json["segment_length"],
    imageUrl: json["image_url"],
    nameLength: json["name_length"],
    version: json["version"],
    url: json["url"],
    sellerFeeBasisPoints: json["seller_fee_basis_points"],
    feeRecipient: json["fee_recipient"],
    youtubeUrl: json["youtube_url"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "image": image,
    "attributes": attributes == null ? null : List<dynamic>.from(attributes!.map((x) => x.toJson())),
    "external_link": externalLink,
    "external_url": externalUrl,
    "dna": dna,
    "edition": edition,
    "compiler": compiler,
    "metadata": metadata == null ? null : List<dynamic>.from(metadata!.map((x) => x)),
    "date": date,
    "id": id,
    "collection": collection,
    "objectID": objectId,
    "animation_url": animationUrl,
    "contract": contract,
    "symbol": symbol,
    "background_color": backgroundColor,
    "background_image": backgroundImage,
    "is_normalized": isNormalized,
    "segment_length": segmentLength,
    "image_url": imageUrl,
    "name_length": nameLength,
    "version": version,
    "url": url,
    "seller_fee_basis_points": sellerFeeBasisPoints,
    "fee_recipient": feeRecipient,
    "youtube_url": youtubeUrl,
  };
}

class Attribute {
  Attribute({
    this.value,
    this.traitType,
    this.displayType,
  });

  dynamic value;
  String? traitType;
  DisplayType? displayType;

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
    value: json["value"],
    traitType: json["trait_type"],
    displayType: json["display_type"] == null ? null : displayTypeValues.map[json["display_type"]],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "trait_type": traitType,
    "display_type": displayType == null ? null : displayTypeValues.reverse[displayType],
  };
}

enum DisplayType { NUMBER, DATE, STRING }

final displayTypeValues = EnumValues({
  "date": DisplayType.DATE,
  "number": DisplayType.NUMBER,
  "string": DisplayType.STRING
});

class TokenUri {
  TokenUri({
    this.raw,
    this.gateway,
  });

  String? raw;
  String? gateway;

  factory TokenUri.fromJson(Map<String, dynamic> json) => TokenUri(
    raw: json["raw"],
    gateway: json["gateway"],
  );

  Map<String, dynamic> toJson() => {
    "raw": raw,
    "gateway": gateway,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap;
    return reverseMap!;
  }
}
