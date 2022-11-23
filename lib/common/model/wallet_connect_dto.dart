import 'dart:convert';

WalletConnectDto walletConnectDtoFromJson(String str) => WalletConnectDto.fromJson(json.decode(str));

String walletConnectDtoToJson(WalletConnectDto data) => json.encode(data.toJson());

class WalletConnectDto {
  WalletConnectDto({
    required this.wallet,
    required this.message,
    required this.signature,
  });

  String? wallet;
  String? message;
  String? signature;

  factory WalletConnectDto.fromJson(Map<String, dynamic> json) => WalletConnectDto(
    wallet: json["wallet"],
    message: json["message"],
    signature: json["signature"],
  );

  Map<String, dynamic> toJson() => {
    "wallet": wallet,
    "message": message,
    "signature": signature,
  };
}
