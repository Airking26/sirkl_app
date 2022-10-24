import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class CommonService extends GetConnect{
  Future<Response<Map<String, dynamic>>> addUserToSirkl(String accessToken, String id) => put('${con.URL_SERVER}follow/me/$id', "", headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> removeUserToSirkl(String accessToken, String id) => delete('${con.URL_SERVER}follow/me/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> getSirklUsers(String accessToken, String id) => get('${con.URL_SERVER}follow/$id/following', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchSirklUsers(String accessToken, String name, String offset) => get('${con.URL_SERVER}follow/search/following/$name/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchUsers(String accessToken, String name, String offset) => get('${con.URL_SERVER}search/users/$name/$offset', headers: {'Authorization':'Bearer $accessToken'});
}