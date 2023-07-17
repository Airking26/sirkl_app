
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/report_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

import '../common/model/notification_added_admin_dto.dart';
import '../common/model/sign_in_success_dto.dart';

class CommonRepo {
  static Future<UserDTO> addUserToSirkl(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.put(url: SUrls.followMeById(id), body: null);
    return UserDTO.fromJson(res.jsonBody());
    //return (res.jsonBody() as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }
    static Future<UserDTO> removeUserToSirkl(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.delete(url: SUrls.followMeById(id));
    return UserDTO.fromJson(res.jsonBody());
    //return (res.jsonBody() as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }
   static Future<List<UserDTO>> getSirklUsers(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.followByIdFollowing(id));

    return (res.jsonBody() as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }
  static Future<bool> checkUserIsInFollowing(String id) async {
     SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.followIsInFollowing(id));
    return res.body == 'true';
  }
  static Future<void> notifyAddedInGroup(NotificationAddedAdminDto notificationAddedAdminDto) async { 
         SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.notificationAddedInGroup, body: notificationAddedAdminDto.toJson() );
  }
    static Future<void> notifyUserAsAdmin(NotificationAddedAdminDto notificationAddedAdminDto) async { 
         SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.notificationUpgradedAsAdmin, body: notificationAddedAdminDto.toJson() );
  }

      static Future<void> report(ReportDto reportDto) async { 
         SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.signalmentReport, body: reportDto.toJson() );
  }
  

  //Future<Response<List<dynamic>>> searchSirklUsers(String accessToken, String name, String offset) => get('${con.URL_SERVER}follow/search/following/$name/$offset', headers: {'Authorization':'Bearer $accessToken'});
}