import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class CommonService extends GetConnect{
  Future<Response<Map<String, dynamic>>> addUserToSirkl(String accessToken, String id) => put('${con.URL_SERVER}follow/me/$id', "", headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> removeUserToSirkl(String accessToken, String id) => delete('${con.URL_SERVER}follow/me/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> checkUserIsInFollowing(String accessToken, String id) => get('${con.URL_SERVER}follow/isInFollowing/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> getSirklUsers(String accessToken, String id) => get('${con.URL_SERVER}follow/$id/following', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchSirklUsers(String accessToken, String name, String offset) => get('${con.URL_SERVER}follow/search/following/$name/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchUsers(String accessToken, String name, String offset) => get('${con.URL_SERVER}search/users/$name/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> retrieveNicknames(String accessToken) => get('${con.URL_SERVER}nicknames/retrieve', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> addNickname(String accessToken, String wallet, String nickname) => put('${con.URL_SERVER}nicknames/$wallet/$nickname', null,  headers: {'Authorization':'Bearer $accessToken'});
}