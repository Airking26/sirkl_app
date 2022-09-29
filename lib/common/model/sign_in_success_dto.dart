import 'dart:convert';

SignInSuccessDto signInSuccessDtoFromJson(String str) => SignInSuccessDto.fromJson(json.decode(str));
String signInSuccessDtoToJson(SignInSuccessDto data) => json.encode(data.toJson());
User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User user) => json.encode(user.toJson());

class SignInSuccessDto {
  SignInSuccessDto({
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  User? user;
  String? accessToken;
  String? refreshToken;

  factory SignInSuccessDto.fromJson(Map<String, dynamic> json) => SignInSuccessDto(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
  );

  Map<String, dynamic> toJson() => {
    "user": user == null ? null : user?.toJson(),
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}

class User {
  User({
    this.id,
    this.userName,
    this.picture,
    this.isAdmin,
    this.createdAt,
    this.description,
    this.fcmToken,
    this.wallet,
  });

  String? id;
  String? userName;
  String? picture;
  bool? isAdmin;
  DateTime? createdAt;
  String? description;
  String? fcmToken;
  String? wallet;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    userName: json["userName"],
    picture: json["picture"],
    isAdmin: json["isAdmin"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    description: json["description"],
    fcmToken: json["fcmToken"],
    wallet: json["wallet"],
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
  };
}
