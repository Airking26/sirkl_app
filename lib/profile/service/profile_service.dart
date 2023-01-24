import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ProfileService extends GetConnect{
  Future<Response<Map<String, dynamic>>> modifyUser(String accessToken, String updateUserInfoDTO) => patch('${con.URL_SERVER}user/me', updateUserInfoDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<dynamic>> getUserByWallet(String accessToken, String wallet) => get('${con.URL_SERVER}user/search/$wallet', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> getUserByID(String accessToken, String id) => get('${con.URL_SERVER}user/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> retrieveTokenStreamChat(String accessToken) => get('${con.URL_SERVER}user/me/tokenStreamChat', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> retrieveTokenAgoraRTC(String accessToken, String channel, String role, String tokenType, String id) => get('${con.URL_SERVER}user/me/tokenAgoraRTC/$channel/$role/$tokenType/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> retrieveTokenAgoraRTM(String accessToken, String id) => get('${con.URL_SERVER}user/me/tokenAgoraRTM/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> retrieveHasUnreadNotif(String accessToken, String id) => get('${con.URL_SERVER}notification/$id/unreadNotif', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> postStory(String accessToken, String storyCreationDTO) => post('${con.URL_SERVER}story/create', storyCreationDTO,  headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveNotifications(String accessToken, String id, String offset) => get('${con.URL_SERVER}notification/$id/notifications/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> deleteUser(String accessToken, String id) => delete("${con.URL_SERVER}user/$id", headers: {'Authorization':'Bearer $accessToken'});
}