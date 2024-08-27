import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

import '../common/model/call_creation_dto.dart';
import '../common/model/call_dto.dart';
import '../common/model/call_modification_dto.dart';
import '../common/model/sign_in_success_dto.dart';

class CallRepo {
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
    Response res = await req.get(SUrls.callRetrieveByOffset(offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => CallDto.fromJson(e))
        .toList();
  }

  static Future<List<UserDTO>> searchUser(
      String substring, String offset) async {
    SRequests req = SRequests(SUrls.baseURL);

    Response res =
        await req.get(SUrls.searchUsersBySubstringOffset(substring, offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }

  static Future<void> endCall(String id, String channel) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.callEndByIdChannel(id, channel));
  }

  static Future<void> missedCallNotification(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.callMissedCallById(id));
  }

  static Future<List<CallDto>> searchCalls(String substring) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.callRetrieveByOffset(substring));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => CallDto.fromJson(e))
        .toList();
  }
}
