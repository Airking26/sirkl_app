import 'package:sirkl/models/request_to_join_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class JoinRepo {
  static Future<void> requestToJoinGroup(RequestToJoinDto requestToJoin) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.joinRequestToJoin, body: requestToJoin.toJson());
  }

  static Future<void> acceptDeclineRequest(
      RequestToJoinDto requestToJoin) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.joinAcceptDeclineRequest, body: requestToJoin.toJson());
  }

  static Future<List<UserDTO>> getRequestsWaiting(String channelId) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.joinRequestsByChannelId(channelId));
    return (res as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }
}
