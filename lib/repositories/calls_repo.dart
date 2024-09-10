import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

import '../models/call_creation_dto.dart';
import '../models/call_dto.dart';
import '../models/call_modification_dto.dart';

class CallRepo {
  static Future<void> endCall(String id, String channel) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.callEndByIdChannel(id, channel));
  }

  static Future<void> missedCallNotification(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.callMissedCallById(id));
  }

  static Future<void> createCall(CallCreationDto callCreationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.callCreate, body: callCreationDto.toJson());
  }

  static Future<void> updateCall(
      CallModificationDto callModificationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.callUpdate, body: callModificationDto.toJson());
  }

  static Future<List<CallDto>> retrieveCalls(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveCalls(offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => CallDto.fromJson(e))
        .toList();
  }

  static Future<List<CallDto>> searchCalls(String substring) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.callSearchBySubstring(substring));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => CallDto.fromJson(e))
        .toList();
  }
}
