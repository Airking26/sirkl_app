import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ProfileService extends GetConnect{

  Future<Response<Map<String, dynamic>>> modifyUser(String accessToken, String updateUserInfoDTO) => patch('${con.URL_SERVER}user/me', updateUserInfoDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> modifyPassword(String accessToken, String wallet, String password) => patch('${con.URL_SERVER}user/modifyPassword/$wallet/$password', "", headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> retrieveTokenZegoCloud(String accessToken) => get('${con.URL_SERVER}user/me/tokenZegoCloud', headers: {'Authorization':'Bearer $accessToken'});


}