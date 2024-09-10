import 'package:sirkl/models/nickname_creation_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class NicknameRepo {
  static Future<void> updateNicknames(
      {required String wallet,
      required NicknameCreationDto nickNameDto}) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.put(
        url: '${SUrls.nicknames}/$wallet', body: nickNameDto.toJson());
  }

  static Future<Map<String, dynamic>> retrieveNicknames() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.nicknamesRetrieve);
    return res.jsonBody();
  }
}
