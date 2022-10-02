import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ProfileService extends GetConnect{

  Future<Response<Map<String, dynamic>>> modifyUser(String accessToken, String updateUserInfoDTO) => patch('${con.URL_SERVER}user/me', updateUserInfoDTO, headers: {'Authorization':'Bearer $accessToken'});


}