import 'dart:convert';

NftModificationDto nftModificationDtoFromJson(String str) =>
    NftModificationDto.fromJson(json.decode(str));

String nftModificationDtoToJson(NftModificationDto data) =>
    json.encode(data.toJson());

class NftModificationDto {
  NftModificationDto({
    required this.contractAddress,
    required this.id,
    required this.isFav,
  });

  String contractAddress;
  String id;
  bool isFav;

  factory NftModificationDto.fromJson(Map<String, dynamic> json) =>
      NftModificationDto(
        id: json["id"],
        contractAddress: json["contractAddress"],
        isFav: json["isFav"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "contractAddress": contractAddress,
        "isFav": isFav,
      };
}
