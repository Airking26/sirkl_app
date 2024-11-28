// To parse this JSON data, do
//
//     final userProgressDto = userProgressDtoFromJson(jsonString);

import 'dart:convert';

import 'sign_in_success_dto.dart';

UserProgressDto userProgressDtoFromJson(String str) =>
    UserProgressDto.fromJson(json.decode(str));

String userProgressDtoToJson(UserProgressDto data) =>
    json.encode(data.toJson());

class UserProgressDto {
  bool? bonusAwarded;
  UserDTO? user;
  String? gamificationId;
  List<TaskProgress>? taskProgress;

  UserProgressDto({
    this.bonusAwarded,
    this.user,
    this.gamificationId,
    this.taskProgress,
  });

  factory UserProgressDto.fromJson(Map<String, dynamic> json) =>
      UserProgressDto(
        bonusAwarded: json["bonusAwarded"],
        user: json["user"] == null ? null : UserDTO.fromJson(json["user"]),
        gamificationId: json["gamificationId"],
        taskProgress: json["taskProgress"] == null
            ? []
            : List<TaskProgress>.from(
                json["taskProgress"]!.map((x) => TaskProgress.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bonusAwarded": bonusAwarded,
        "user": user == null ? null : user?.toJson(),
        "gamificationId": gamificationId,
        "taskProgress": taskProgress == null
            ? []
            : List<dynamic>.from(taskProgress!.map((x) => x.toJson())),
      };
}

class TaskProgress {
  String? taskName;
  String? taskDescription;
  int? points;
  bool? completed;
  dynamic completedAt;

  TaskProgress({
    this.taskName,
    this.taskDescription,
    this.points,
    this.completed,
    this.completedAt,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) => TaskProgress(
        taskName: json["taskName"],
        taskDescription: json["taskDescription"],
        points: json["points"],
        completed: json["completed"],
        completedAt: json["completedAt"],
      );

  Map<String, dynamic> toJson() => {
        "taskName": taskName,
        "taskDescription": taskDescription,
        "points": points,
        "completed": completed,
        "completedAt": completedAt,
      };
}
