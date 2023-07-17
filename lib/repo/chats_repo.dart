import 'package:flutter/cupertino.dart';

import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

import '../common/model/inbox_creation_dto.dart';
import '../common/model/request_to_join_dto.dart';
import '../common/model/sign_in_success_dto.dart';

class ChatRepo {
  static Future<String> createInbox(InboxCreationDto inboxCreationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.inboxCreate, body: inboxCreationDto.toJson());
    return res.body;
  }

  static Future<void> walletsToMessages() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.inboxUpdate);
  
  }
  static Future<String?> ethFromEns(String ens) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.inboxEthFromENS(ens));

    return res.body == null? null: res.body.toString();
  }
  static Future<void> deleteInbox(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.delete(url: SUrls.inboxDeleteById(id));
  }
  static Future<void> requestToJoinGroup(RequestToJoinDto requestToJoin) async {
      SRequests req = SRequests(SUrls.baseURL);
      Response res = await req.post(url: SUrls.joinRequestToJoin, body: requestToJoin.toJson());
  }
  
  static Future<void> acceptDeclineRequest(RequestToJoinDto requestToJoin) async {
      SRequests req = SRequests(SUrls.baseURL);
      Response res = await req.post(url: SUrls.joinAcceptDeclineRequest, body: requestToJoin.toJson());
  }
  static Future<List<UserDTO>> getRequestsWaiting(String channelId) async {
      SRequests req = SRequests(SUrls.baseURL);
      Response res = await req.get(SUrls.joinRequestsByChannelId(channelId));
      return (res as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }

}