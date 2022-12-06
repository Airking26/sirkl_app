import 'dart:convert';

EnsDto ensDtoFromJson(String str) => EnsDto.fromJson(json.decode(str));

String ensDtoToJson(EnsDto data) => json.encode(data.toJson());

class EnsDto {
  EnsDto({
    required this.data,
  });

  final Data data;

  factory EnsDto.fromJson(Map<String, dynamic> json) => EnsDto(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.domains,
  });

  final List<Domain> domains;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    domains: List<Domain>.from(json["domains"].map((x) => Domain.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "domains": List<dynamic>.from(domains.map((x) => x.toJson())),
  };
}

class Domain {
  Domain({
    required this.name,
    required this.owner,
  });

  final String name;
  final Owner owner;

  factory Domain.fromJson(Map<String, dynamic> json) => Domain(
    name: json["name"],
    owner: Owner.fromJson(json["owner"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner.toJson(),
  };
}

class Owner {
  Owner({
    required this.id,
  });

  final String id;

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}
