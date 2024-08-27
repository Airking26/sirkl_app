import 'dart:convert';

ContractCreatorDto? contractCreatorDtoFromJson(String str) =>
    ContractCreatorDto.fromJson(json.decode(str));

String contractCreatorDtoToJson(ContractCreatorDto? data) =>
    json.encode(data!.toJson());

class ContractCreatorDto {
  ContractCreatorDto({
    this.status,
    this.message,
    this.result,
  });

  String? status;
  String? message;
  List<Result?>? result;

  factory ContractCreatorDto.fromJson(Map<String, dynamic> json) =>
      ContractCreatorDto(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : json["result"] == null
                ? []
                : List<Result?>.from(
                    json["result"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : result == null
                ? []
                : List<dynamic>.from(result!.map((x) => x!.toJson())),
      };
}

class Result {
  Result({
    this.contractAddress,
    this.contractCreator,
    this.txHash,
  });

  String? contractAddress;
  String? contractCreator;
  String? txHash;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        contractAddress: json["contractAddress"],
        contractCreator: json["contractCreator"],
        txHash: json["txHash"],
      );

  Map<String, dynamic> toJson() => {
        "contractAddress": contractAddress,
        "contractCreator": contractCreator,
        "txHash": txHash,
      };
}
