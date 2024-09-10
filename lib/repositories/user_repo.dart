import 'package:sirkl/models/admin_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/update_fcm_dto.dart';
import 'package:sirkl/models/update_me_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class UserRepo {
  static Future<UserDTO> retrieveUser() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userMe);
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<UserDTO> modifyUser(UpdateMeDto updateMeDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res =
        await req.patch(url: SUrls.userMe, body: updateMeDto.toJson());
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<void> deleteUser(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.delete(url: SUrls.userById(id));
  }

  static Future<UserDTO> getUserByID(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userById(id));
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<UserDTO> uploadFCMToken(UpdateFcmdto fcmBody) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.put(url: SUrls.userMeFCM, body: fcmBody.toJson());
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<void> uploadAPNToken(String apnToken) async =>
      await SRequests(SUrls.baseURL)
          .put(url: '${SUrls.userMeAPN}/$apnToken', body: null);

  static Future<UserDTO> getUserByWallet(String wallet) async {
    SRequests req = SRequests(SUrls.baseURL);

    Response res = await req.get(SUrls.userSearchByWallet(wallet));
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<String> retrieveTokenStreamChat() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userMeTokenStreamChat);
    return res.body;
  }

  static Future<void> changeAdminRole(AdminDto adminDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.userAdminRole, body: adminDto.toJson());
  }

  //TODO : Migrate to server
  static Future<void> addUserToSirklClub(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.userAddSirklClub(id));
  }

  //TODO : Migrate to server
  static Future<void> receiveWelcomeMessage() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.userMeWelcomeMessage);
  }

  static Future<String> retrieveTokenAgoraRTC(
      String channel, String role, String tokenType, String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res =
        await req.get(SUrls.userMeTokenAgoraRTC(channel, role, tokenType, id));
    return res.body;
  }

  static Future<bool> checkIsUsernameAvailable(String value) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.checkIsUsernameAvailable(value));
    return res.jsonBody();
  }
}
