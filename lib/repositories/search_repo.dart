import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class SearchRepo {
  static Future<List<UserDTO>> searchUser(
      String substring, String offset) async {
    SRequests req = SRequests(SUrls.baseURL);

    Response res =
        await req.get(SUrls.searchUsersBySubstringOffset(substring, offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }
}
