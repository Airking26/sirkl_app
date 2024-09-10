import 'dart:convert';

adminDtoFromJson(String str) => AdminDto.fromJson(json.decode(str));

String adminDtoToJson(AdminDto data) => json.encode(data.toJson());

class AdminDto {
  AdminDto({
    required this.idChannel,
    required this.userToUpdate,
    required this.makeAdmin,
  });

  String idChannel;
  String userToUpdate;
  bool makeAdmin;

  factory AdminDto.fromJson(Map<String, dynamic> json) => AdminDto(
        idChannel: json["idChannel"],
        userToUpdate: json["userToUpdate"],
        makeAdmin: json["makeAdmin"],
      );

  Map<String, dynamic> toJson() => {
        "idChannel": idChannel,
        "userToUpdate": userToUpdate,
        "makeAdmin": makeAdmin,
      };
}
