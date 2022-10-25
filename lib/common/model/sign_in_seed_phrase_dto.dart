import 'dart:convert';

SignInSeedPhraseDto signInSeedPhraseDtoFromJson(String str) => SignInSeedPhraseDto.fromJson(json.decode(str));

String signInSeedPhraseDtoToJson(SignInSeedPhraseDto data) => json.encode(data.toJson());

class SignInSeedPhraseDto {
  SignInSeedPhraseDto({
    required this.wallet,
    required this.seedPhrase,
  });

  String? wallet;
  String? seedPhrase;

  factory SignInSeedPhraseDto.fromJson(Map<String, dynamic> json) => SignInSeedPhraseDto(
    wallet: json["wallet"],
    seedPhrase: json["seedPhrase"],
  );

  Map<String, dynamic> toJson() => {
    "wallet": wallet,
    "seedPhrase": seedPhrase,
  };
}
