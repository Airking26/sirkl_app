import 'dart:convert';

RequestToJoinDto requestToJoinDtoFromJson(String str) =>
    RequestToJoinDto.fromJson(json.decode(str));

String requestToJoinDtoToJson(RequestToJoinDto data) =>
    json.encode(data.toJson());

class RequestToJoinDto {
  RequestToJoinDto(
      {this.receiver,
      this.requester,
      this.channelId,
      this.channelName,
      this.accept,
      this.paying});

  String? receiver;
  String? requester;
  String? channelId;
  String? channelName;
  bool? accept;
  bool? paying;

  factory RequestToJoinDto.fromJson(Map<String, dynamic> json) =>
      RequestToJoinDto(
          receiver: json["receiver"],
          requester: json["requester"],
          channelId: json["channelId"],
          channelName: json["channelName"],
          accept: json["accept"],
          paying: json["paying"]);

  Map<String, dynamic> toJson() => {
        "receiver": receiver,
        "requester": requester,
        "channelId": channelId,
        "channelName": channelName,
        "accept": accept,
        "paying": paying
      };
}
