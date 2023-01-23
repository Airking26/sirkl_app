import 'dart:convert';

List<NftDto> nftDtoFromJson(String str) => List<NftDto>.from(json.decode(str).map((x) => NftDto.fromJson(x)));

String nftDtoToJson(List<NftDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NftDto {
  NftDto({
    this.id,
    this.title,
    this.images,
    this.collectionImage,
    this.contractAddress,
    this.isFav,
  });

  String? id;
  String? title;
  List<String>? images;
  String? collectionImage;
  String? contractAddress;
  bool? isFav;

  factory NftDto.fromJson(Map<String, dynamic> json) => NftDto(
    id: json["id"],
    title: json["title"],
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    collectionImage: json["collectionImage"],
    contractAddress: json["contractAddress"],
    isFav: json["isFav"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "collectionImage": collectionImage,
    "contractAddress": contractAddress,
    "isFav": isFav,
  };
}