import 'dart:convert';

WebWalletConnectDto webWalletConnectDtoFromJson(String str) =>
    WebWalletConnectDto.fromJson(json.decode(str));

String webWalletConnectDtoToJson(WebWalletConnectDto data) =>
    json.encode(data.toJson());

class WebWalletConnectDto {
  WebWalletConnectDto(
      {required this.wallet,
      required this.message,
      required this.signature,
      required this.timestamp});

  String? wallet;
  String? message;
  String? signature;
  String? timestamp;

  factory WebWalletConnectDto.fromJson(Map<String, dynamic> json) =>
      WebWalletConnectDto(
          wallet: json["wallet"],
          message: json["message"],
          signature: json["signature"],
          timestamp: json["timestamp"]);

  Map<String, dynamic> toJson() => {
        "wallet": wallet,
        "message": message,
        "signature": signature,
        "timestamp": timestamp
      };
}
