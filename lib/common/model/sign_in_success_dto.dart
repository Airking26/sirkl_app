import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';

SignInSuccessDto signInSuccessDtoFromJson(String str) => SignInSuccessDto.fromJson(json.decode(str));
String signInSuccessDtoToJson(SignInSuccessDto data) => json.encode(data.toJson());
UserDTO userFromJson(String str) => UserDTO.fromJson(json.decode(str));
String userToJson(UserDTO user) => json.encode(user.toJson());

class SignInSuccessDto {
  SignInSuccessDto({
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  UserDTO? user;
  String? accessToken;
  String? refreshToken;

  factory SignInSuccessDto.fromJson(Map<String, dynamic> json) => SignInSuccessDto(
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

class UserDTO extends ISuspensionBean{
  UserDTO({
    this.id,
    this.userName,
    this.picture,
    this.isAdmin,
    this.createdAt,
    this.description,
    this.fcmToken,
    this.wallet,
    this.contractAddresses,
    this.following,
    this.isInFollowing,
  });

  String? id;
  String? userName;
  String? picture;
  bool? isAdmin;
  DateTime? createdAt;
  String? description;
  String? fcmToken;
  String? wallet;
  List<String>? contractAddresses;
  int? following;
  bool? isInFollowing;

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
    id: json["id"],
    userName: json["userName"],
    picture: json["picture"],
    isAdmin: json["isAdmin"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    description: json["description"],
    fcmToken: json["fcmToken"],
    wallet: json["wallet"],
    contractAddresses: json["contractAddresses"] == null ? null : List<String>.from(json["contractAddresses"].map((x) => x)),
    following: json["following"],
    isInFollowing: json["isInFollowing"],
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
    "contractAddresses": contractAddresses == null ? null : List<dynamic>.from(contractAddresses!.map((x) => x)),
    "following": following,
    "isInFollowing": isInFollowing,
  };

  @override
  String getSuspensionTag() => userName.isNullOrBlank! ? wallet![0] : userName![0];
}
