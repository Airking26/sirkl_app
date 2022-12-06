import 'dart:convert';

MoralisMetadataDto moralisMetadataDtoFromJson(String str) => MoralisMetadataDto.fromJson(json.decode(str));

String moralisMetadataDtoToJson(MoralisMetadataDto data) => json.encode(data.toJson());

class MoralisMetadataDto {
  MoralisMetadataDto({
    this.name,
    this.description,
    this.image,
    this.externalUrl,
    //this.attributes,
  });

  String? name;
  String? description;
  String? image;
  String? externalUrl;
  //List<dynamic>? attributes;

  factory MoralisMetadataDto.fromJson(Map<String, dynamic> json) => MoralisMetadataDto(
    name: json["name"],
    description: json["description"],
    image: json["image"],
    externalUrl: json["external_url"],
   // attributes: json["attributes"] == null ? null : List<Attribute>.from(json["attributes"].map((x) => Attribute.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "image": image,
    "external_url": externalUrl,
    //"attributes": attributes == null ? null : List<dynamic>.from(attributes!.map((x) => x?.toJson())),
  };
}

class Attribute {
  Attribute({
    this.traitType,
    this.value,
  });

  String? traitType;
  dynamic value;

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
    traitType: json["trait_type"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "trait_type": traitType,
    "value": value,
  };
}
