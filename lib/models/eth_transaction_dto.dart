// To parse this JSON data, do
//
//     final ethereumTransaction = ethereumTransactionFromJson(jsonString);

import 'dart:convert';

EthereumTransaction ethereumTransactionFromJson(String str) =>
    EthereumTransaction.fromJson(json.decode(str));

String ethereumTransactionToJson(EthereumTransaction data) =>
    json.encode(data.toJson());

class EthereumTransaction {
  String? from;
  String? to;
  String? value;
  String? nonce;
  String? gasPrice;
  String? maxFeePerGas;
  String? maxPriorityFeePerGas;
  String? gas;
  String? gasLimit;
  String? data;

  EthereumTransaction({
    this.from,
    this.to,
    this.value,
    this.nonce,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.gas,
    this.gasLimit,
    this.data,
  });

  factory EthereumTransaction.fromJson(Map<String, dynamic> json) =>
      EthereumTransaction(
        from: json["from"],
        to: json["to"],
        value: json["value"],
        nonce: json["nonce"],
        gasPrice: json["gasPrice"],
        maxFeePerGas: json["maxFeePerGas"],
        maxPriorityFeePerGas: json["maxPriorityFeePerGas"],
        gas: json["gas"],
        gasLimit: json["gasLimit"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "value": value,
        "nonce": nonce,
        "gasPrice": gasPrice,
        "maxFeePerGas": maxFeePerGas,
        "maxPriorityFeePerGas": maxPriorityFeePerGas,
        "gas": gas,
        "gasLimit": gasLimit,
        "data": data,
      };
}
