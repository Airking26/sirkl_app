
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

import '../common/model/notification_dto.dart';
import '../common/model/sign_in_success_dto.dart';
import '../common/model/story_creation_dto.dart';
import '../common/model/story_dto.dart';
import '../common/model/update_me_dto.dart';

class ProfileRepo {
  static Future<String> retrieveTokenStreamChat() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userMeTokenStreamChat);
    return res.body;
  }

  static Future<UserDTO> retrieveUser() async{
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userMe);
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<UserDTO> modifyUser(UpdateMeDto updateMeDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.patch(url: SUrls.userMe, body: updateMeDto.toJson());
    return UserDTO.fromJson(res.jsonBody());

  }
  static Future<UserDTO> getUserByWallet(String wallet) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get('${SUrls.userSearch}/$wallet');
    return UserDTO.fromJson(res.jsonBody());
  }
  static Future<void> postStory(StoryCreationDto storyDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.storyCreate, body: storyDto.toJson());
  }
  static Future<bool> retrieveHasUnreadNotif(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.notificationUnreadNotif(id));
    return res.body == 'true';
  }
  static Future<List<NotificationDto>> retrieveNotifications({required String id, required String offset}) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.notificationByOffset(id, offset));
    return (res.jsonBody() as List<dynamic>).map((e) => NotificationDto.fromJson(e)).toList();
  }
  static Future<List<StoryDto>> retrieveMyStories() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.storyMine);
    
    return (res.jsonBody() as List<dynamic>).map((e) => StoryDto.fromJson(e)).toList();
  }
  static Future<void> deleteUser(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response  res = await req.delete(url: SUrls.userById(id));

  }
    static Future<void> deleteNotification(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response  res = await req.delete(url: SUrls.notificationById(id));

  }
  static Future<List<UserDTO>> retrieveReadersForAStory(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.storyReadersById(id));
    return (res.jsonBody() as List<dynamic>).map((e) => UserDTO.fromJson(e)).toList();
  }
  static Future<UserDTO> getUserByID(String id) async {
        SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userById(id));
    return UserDTO.fromJson(res.jsonBody());
  }
  static Future<String> retrieveTokenAgoraRTC(String channel, String role, String tokenType, String id) async {
        SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.userMeTokenAgoraRTC(channel, role, tokenType, id));
    return res.body;
  }

  static Future<bool> checkIsUsernameAvailable(String value) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.checkIsUsernameAvailable(value));
    return res.jsonBody();
  }
 
  //Future<Response<String>> retrieveTokenAgoraRTM(String accessToken, String id) => get('${con.URL_SERVER}user/me/tokenAgoraRTM/$id', headers: {'Authorization':'Bearer $accessToken'});




}