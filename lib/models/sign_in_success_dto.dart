import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';

SignInSuccessDto signInSuccessDtoFromJson(String str) =>
    SignInSuccessDto.fromJson(json.decode(str));
String signInSuccessDtoToJson(SignInSuccessDto data) =>
    json.encode(data.toJson());
UserDTO userFromJson(String str) {
  return UserDTO.fromJson(json.decode(str));
}

String userToJson(UserDTO user) => json.encode(user.toJson());

class SignInSuccessDto {
  SignInSuccessDto({
    this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  UserDTO? user;
  String accessToken;
  String refreshToken;

  factory SignInSuccessDto.fromJson(Map<String, dynamic> json) =>
      SignInSuccessDto(
        user: json["user"] == null ? null : UserDTO.fromJson(json["user"]),
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "user": user == null ? null : user?.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class UserDTO extends ISuspensionBean {
  UserDTO(
      {this.id,
      this.userName,
      this.picture,
      this.isAdmin,
      this.createdAt,
      this.description,
      this.fcmToken,
      this.wallet,
      this.following,
      this.isInFollowing,
      this.nickname,
      this.updatedAt,
      this.hasSBT,
      this.isSearchable,
      this.octoPoints});

  String? id;
  String? userName;
  String? picture;
  bool? isAdmin;
  DateTime? createdAt;
  String? description;
  String? fcmToken;
  String? wallet;
  int? following;
  bool? isInFollowing;
  String? nickname;
  DateTime? updatedAt;
  bool? hasSBT;
  bool? isSearchable;
  int? octoPoints;

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
        id: json["id"],
        userName: json["userName"],
        picture: json["picture"],
        isAdmin: json["isAdmin"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        description: json["description"],
        fcmToken: json["fcmToken"],
        wallet: json["wallet"],
        following: json["following"],
        isInFollowing: json["isInFollowing"],
        nickname: json['nickname'],
        hasSBT: json['hasSBT'],
        isSearchable: json['isSearchable'],
        octoPoints: json["octoPoints"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userName": userName,
        "picture": picture,
        "isAdmin": isAdmin,
        "createdAt": createdAt == null ? null : createdAt?.toIso8601String(),
        "description": description,
        "fcmToken": fcmToken,
        "wallet": wallet,
        "following": following,
        "isInFollowing": isInFollowing,
        "nickname": nickname,
        "hasSBT": hasSBT,
        "isSearchable": isSearchable,
        "octoPoints": octoPoints,
        "updatedAt": updatedAt == null ? null : updatedAt?.toIso8601String(),
      };

  @override
  String getSuspensionTag() {
    return nickname.isNullOrBlank!
        ? (userName.isNullOrBlank! ? wallet![0] : userName![0].toUpperCase())
        : nickname![0].toUpperCase();
  }
}
