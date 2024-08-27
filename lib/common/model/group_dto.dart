import 'dart:convert';

List<GroupDto> groupDtoFromJson(String str) =>
    List<GroupDto>.from(json.decode(str).map((x) => GroupDto.fromJson(x)));

String groupDtoToJson(List<GroupDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupDto {
  GroupDto({
    required this.name,
    required this.image,
    required this.contractAddress,
  });

  final String name;
  final String image;
  final String contractAddress;

  factory GroupDto.fromJson(Map<String, dynamic> json) => GroupDto(
        name: json["name"],
        image: json["image"],
        contractAddress: json["contractAddress"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "contractAddress": contractAddress,
      };
}
