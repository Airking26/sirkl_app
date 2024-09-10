import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class FollowRepo {
  static Future<UserDTO> addUserToSirkl(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.put(url: SUrls.followMeById(id), body: null);
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<UserDTO> removeUserToSirkl(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.delete(url: SUrls.followMeById(id));
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<bool> checkUserIsInFollowing(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.followIsInFollowing(id));
    return res.body == 'true';
  }

  static Future<List<UserDTO>> getSirklUsers(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.followByIdFollowing(id));

    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }
}
