import 'package:meta/meta.dart';
import 'dart:convert';

ReportDto reportDtoFromJson(String str) => ReportDto.fromJson(json.decode(str));

String reportDtoToJson(ReportDto data) => json.encode(data.toJson());

class ReportDto {
  String createdBy;
  String idSignaled;
  String description;
  int type;

  ReportDto({
    required this.createdBy,
    required this.idSignaled,
    required this.description,
    required this.type,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) => ReportDto(
    createdBy: json["createdBy"],
    idSignaled: json["idSignaled"],
    description: json["description"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "idSignaled": idSignaled,
    "description": description,
    "type": type,
  };
}
