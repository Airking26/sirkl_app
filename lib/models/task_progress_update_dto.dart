// To parse this JSON data, do
//
//     final taskProgressUpdateDto = taskProgressUpdateDtoFromJson(jsonString);

import 'dart:convert';

TaskProgressUpdateDto taskProgressUpdateDtoFromJson(String str) =>
    TaskProgressUpdateDto.fromJson(json.decode(str));

String taskProgressUpdateDtoToJson(TaskProgressUpdateDto data) =>
    json.encode(data.toJson());

class TaskProgressUpdateDto {
  String? taskName;
  String? cycleType;
  int? points;

  TaskProgressUpdateDto({
    this.taskName,
    this.cycleType,
    this.points,
  });

  factory TaskProgressUpdateDto.fromJson(Map<String, dynamic> json) =>
      TaskProgressUpdateDto(
        taskName: json["taskName"],
        cycleType: json["cycleType"],
        points: json["points"],
      );

  Map<String, dynamic> toJson() => {
        "taskName": taskName,
        "cycleType": cycleType,
        "points": points,
      };
}
