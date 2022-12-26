import 'dart:convert';

List<List<StoryDto>> storyDtoFromJson(String str) => List<List<StoryDto>>.from(json.decode(str).map((x) => List<StoryDto>.from(x.map((x) => StoryDto.fromJson(x)))));

String storyDtoToJson(List<List<StoryDto>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))));

class StoryDto {
  StoryDto({
    required this.createdBy,
    required this.readers,
    required this.url,
    required this.createdAt,
    required this.id
  });

  CreatedBy createdBy;
  List<dynamic> readers;
  String url;
  DateTime createdAt;
  String id;

  factory StoryDto.fromJson(Map<String, dynamic> json) => StoryDto(
    createdBy: CreatedBy.fromJson(json["createdBy"]),
    readers: List<dynamic>.from(json["readers"].map((x) => x)),
    url: json["url"],
    id: json['id'],
    createdAt: DateTime.parse(json["createdAt"])
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy.toJson(),
    "readers": List<dynamic>.from(readers.map((x) => x)),
    "url": url,
    "createdAt": createdAt.toIso8601String(),
    "id": id
  };
}

class CreatedBy {
  CreatedBy({
    required this.id,
    required this.userName,
    required this.isAdmin,
    required this.createdAt,
    required this.description,
    required this.fcmToken,
    required this.wallet,
    required this.contractAddresses,
    required this.following,
    required this.isInFollowing,
    this.picture
  });

  String id;
  String userName;
  bool isAdmin;
  DateTime createdAt;
  String description;
  String fcmToken;
  String wallet;
  List<String> contractAddresses;
  int following;
  bool isInFollowing;
  String? picture;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"],
    userName: json["userName"],
    isAdmin: json["isAdmin"],
    createdAt: DateTime.parse(json["createdAt"]),
    description: json["description"],
    fcmToken: json["fcmToken"],
    wallet: json["wallet"],
    contractAddresses: List<String>.from(json["contractAddresses"].map((x) => x)),
    following: json["following"],
    isInFollowing: json["isInFollowing"],
    picture: json["picture"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userName": userName,
    "isAdmin": isAdmin,
    "createdAt": createdAt.toIso8601String(),
    "description": description,
    "fcmToken": fcmToken,
    "wallet": wallet,
    "contractAddresses": List<dynamic>.from(contractAddresses.map((x) => x)),
    "following": following,
    "isInFollowing": isInFollowing,
    "picture": picture
  };
}
