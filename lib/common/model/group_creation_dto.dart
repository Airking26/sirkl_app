import 'dart:convert';

GroupCreationDto groupCreationDtoFromJson(String str) => GroupCreationDto.fromJson(json.decode(str));

String groupCreationDtoToJson(GroupCreationDto data) => json.encode(data.toJson());

class GroupCreationDto {
  GroupCreationDto({
    required this.name,
    required this.picture,
    required this.contractAddress,
  });

  String name;
  String picture;
  String contractAddress;

  factory GroupCreationDto.fromJson(Map<String, dynamic> json) => GroupCreationDto(
    name: json["name"],
    picture: json["picture"],
    contractAddress: json["contractAddress"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "picture": picture,
    "contractAddress": contractAddress,
  };
}
